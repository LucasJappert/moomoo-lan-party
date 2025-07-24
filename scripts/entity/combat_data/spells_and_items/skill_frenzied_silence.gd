class_name SkillFrenziedSilence
extends SkillBase

const NAME = "Frenzied Silence"
const ICON_SLOT = Vector2(6, 0)

static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.2, 0.3, 0.4]
	aux_array[1] = [80, 110, 140]
	aux_array[2] = [10, 8, 6]
	aux_array[3] = [6, 6, 6]

	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].create_effect = true
		_SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		_SKILLS[NAME].item_skill_base[i].stats.attack_speed_percent = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].stats.silence_duration = aux_array[3][i]
		_SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[1][i]
		_SKILLS[NAME].item_skill_base[i].cooldown = aux_array[2][i]
		_SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[3][i]
		_SKILLS[NAME].item_skill_base[i].description = (
			"Grants a " + StringHelpers.format_percent(aux_array[0][i]) + " attack speed boost for " + str(aux_array[3][i]) +
			" seconds. Also gets silenced for the same duration."
		)

static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false
	
	if not _target or not _learned_skill: return false

	var new_effect = CombatEffect.get_effect_from_item_skill_base(_learned_skill)
	_target.effects_helper.add_effect(new_effect)

	return true
