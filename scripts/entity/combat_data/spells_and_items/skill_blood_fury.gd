class_name SkillBloodFury
extends SkillBase

const NAME: String = "Blood Fury"
const ICON_SLOT = Vector2(1, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.1, 0.15, 0.2]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].target_to_enemy = true
		SKILLS[NAME].item_skill_base[i].float_dict["perc_attack_speed_per_stack"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].float_dict["perc_attack_power_per_stack"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].en_description = "Gives " + StringHelpers.format_percent(aux_array[0][i]) + " extra physical attack power and attack speed per each 10% of lost hp."
		SKILLS[NAME].item_skill_base[i].es_description = "Otorga un " + StringHelpers.format_percent(aux_array[0][i]) + " adicional de poder de ataque físico y velocidad de ataque por cada 10% de vida perdida."

func _init(p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	permanent_effect = true

static func actions_after_current_hp_updated(_increased_value: int, _owner: Entity) -> void:
	var _learned_skill := _owner.get_learned_skill(NAME)
	if not _learned_skill: return

	var current_hp = _owner.current_hp
	var full_health: float = _owner.get_full_health()
	var percent_lost_hp: float = floor((1 - current_hp / full_health) * 10.0) / 10.0
	if percent_lost_hp <= 0: return _owner.remove_effect_by_name(NAME)

	var effect_stats := CombatStats.new()
	effect_stats.set_level(int(percent_lost_hp * 10)) # Should be 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	var skill_percent: float = _learned_skill.float_dict["perc_attack_speed_per_stack"]
	var extra_percent: float = skill_percent * effect_stats.get_level()
	effect_stats.set_attack_speed_percent(_owner.cache_total_stats_no_effects.get_attack_speed_percent() * extra_percent)
	var extra_damage: int = int(_owner.cache_total_stats_no_effects.get_physical_attack_power() * extra_percent)
	effect_stats.set_physical_attack_power(extra_damage)

	var existing_effect = _owner.effects_helper.get_effect_by_name(NAME)
	if existing_effect and existing_effect.get_level() == effect_stats.get_level(): return

	_owner.remove_effect_by_name(NAME)

	var new_effect = CombatEffect.get_permanent_effect(NAME, SKILLS[NAME].region_rect, _learned_skill.max_stacks, effect_stats.get_info())
	_owner.effects_helper.add_effect(new_effect)
