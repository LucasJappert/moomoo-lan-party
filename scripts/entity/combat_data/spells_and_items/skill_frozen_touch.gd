class_name SkillFrozenTouch
extends SkillBase

const NAME = "Frozen Touch"
const ICON_SLOT = Vector2(3, 0)

func _init(p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	permanent_effect = true

static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [3, 4, 5]
	aux_array[1] = [0.1]
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].apply_to_enemy = true
		_SKILLS[NAME].item_skill_base[i].float_dict[CombatStats.ATTACK_SPEED_PERCENT] = aux_array[1][0]
		_SKILLS[NAME].item_skill_base[i].float_dict[CombatStats.MOVE_SPEED_PERCENT] = aux_array[1][0]
		_SKILLS[NAME].item_skill_base[i].duration_in_seconds = 4
		_SKILLS[NAME].item_skill_base[i].max_stacks = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].description = "The attacker's icy touch partially freezes the target, reducing their movement and attack speed by " + StringHelpers.format_percent(aux_array[1][0]) + " for " + str(_SKILLS[NAME].item_skill_base[i].duration_in_seconds) + " seconds."

		
static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if _di.was_reflected or _di.was_a_cleave_damage or _di.temporal_damage: return false
	if _di.damage_type != DamageType.PHYSICAL: return false

	var _learned_skill := _attacker.get_learned_skill(NAME)
	if not _learned_skill: return false

	var effect = CombatEffect.get_effect_from_item_skill_base(_learned_skill)
	_target.effects_helper.add_effect(effect)
	SoundsHelper.play_random_ice_hit()

	return true
	
static func actions_after_skill_updated(_owner: Entity, _skill: Skill) -> bool:
	if _skill.get_name() != NAME: return false
	if not _skill.get_learned_skill(): return false

	_owner.add_active_skill(SkillMultipleStrike.new(_skill.get_learned_skill()))

	return true
