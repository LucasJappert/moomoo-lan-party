class_name SkillBloodFury
extends SkillBase

const NAME: String = "Blood Fury"
const ICON_SLOT = Vector2(1, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.1, 0.15, 0.2]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = true
		SKILLS[NAME].item_skill_base[i].float_dict["perc_attack_speed_per_stack"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].float_dict["perc_attack_power_per_stack"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].description = "Gives " + StringHelpers.format_percent(aux_array[0][i]) + " extra physical attack power and attack speed per each 10% of lost hp."

static func actions_after_current_hp_updated(_increased_value: int, _attacker: Entity) -> void:
	var _learned_skill := _attacker.get_learned_skill(NAME)
	if not _learned_skill: return

	# var current_hp = _attacker.current_hp
	# var total_hp: float = my_owner.get_total_hp()
	# var percent_lost_hp: float = floor((1 - current_hp / total_hp) * 10.0) / 10.0
	# if percent_lost_hp <= 0: return

	# var effect_stats = CombatStats.new()
	# effect_stats.physical_attack_power = _attacker.cache_total_stats_no_effects.physical_attack_power * percent_lost_hp
	# effect_stats.attack_speed = _attacker.cache_total_stats_no_effects.attack_speed * percent_lost_hp
	# effect_stats.level = percent_lost_hp * 10 # Should be 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

	# var existing_effect = _attacker.effects_helper.get_effect_by_name(NAME)
	# if existing_effect:
	# 	if existing_effect.stats.level == effect_stats.level: return

	# _attacker.remove_effect_by_name(NAME)

	# var new_effect = CombatEffect.get_permanent_effect(NAME, SKILLS[NAME].region_rect, _learned_skill.max_stacks, effect_stats)
	# _attacker.effects_helper.add_effect(new_effect)
