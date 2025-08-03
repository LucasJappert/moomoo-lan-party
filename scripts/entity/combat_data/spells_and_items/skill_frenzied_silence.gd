class_name SkillFrenziedSilence
extends SkillBase

const NAME = "Frenzied Silence"
const ICON_SLOT = Vector2(6, 0)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.6, 0.8, 1]
	aux_array[1] = [80, 110, 140]
	aux_array[2] = [20, 17, 14]
	aux_array[3] = [12, 12, 12]

	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].create_effect = true
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 7
		SKILLS[NAME].item_skill_base[i].set_attack_speed_percent(aux_array[0][i])
		SKILLS[NAME].item_skill_base[i].set_silence_duration(aux_array[3][i])
		SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].cooldown = aux_array[2][i]
		SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[3][i]
		SKILLS[NAME].item_skill_base[i].description = (
			"Grants a " + StringHelpers.format_percent(aux_array[0][i]) + " attack speed boost for " + str(aux_array[3][i]) +
			" seconds. Also gets silenced for the same duration."
		)

static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false
	
	if not _target or not _learned_skill: return false

	var new_effect = CombatEffect.get_effect_from_item_skill_base(_learned_skill, SKILLS[NAME].region_rect)
	_target.effects_helper.add_effect(new_effect)

	return true
