class_name SkillFrozenTouch
extends SkillBase

const NAME = "Frozen Touch"
const ICON_SLOT = Vector2(3, 0)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [3, 4, 5]
	aux_array[1] = [0.1]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = true
		SKILLS[NAME].item_skill_base[i].set_attack_speed_percent(-aux_array[1][0])
		SKILLS[NAME].item_skill_base[i].set_move_speed_percent(-aux_array[1][0])
		SKILLS[NAME].item_skill_base[i].set_freeze_duration(4)
		SKILLS[NAME].item_skill_base[i].duration_in_seconds = 4
		SKILLS[NAME].item_skill_base[i].max_stacks = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].description = "The attacker's icy touch partially freezes the target, reducing their movement and attack speed by " + StringHelpers.format_percent(aux_array[1][0]) + " for " + str(SKILLS[NAME].item_skill_base[i].duration_in_seconds) + " seconds."

		
static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if _di.was_reflected or _di.was_a_cleave_damage or _di.temporal_damage: return false
	if _di.damage_type != DamageType.PHYSICAL: return false

	var _learned_skill := _attacker.get_learned_skill(NAME)
	if not _learned_skill: return false

	var effect = CombatEffect.get_effect_from_item_skill_base(_learned_skill, SKILLS[NAME].region_rect)
	_target.effects_helper.add_effect(effect)
	SoundsHelper.play_random_ice_hit()

	return true
