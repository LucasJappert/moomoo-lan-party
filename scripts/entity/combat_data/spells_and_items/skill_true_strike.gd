class_name SkillTrueStrike
extends SkillBase

const NAME = "True Strike"
const ICON_SLOT = Vector2(3, 1)

static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.4, 0.7, 1]
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 0
		_SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		_SKILLS[NAME].item_skill_base[i].float_dict["chance_to_ignore_evasion"] = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].description = "Grants " + StringHelpers.format_percent(aux_array[0][i]) + " chance to ignore the target's evasion."

static func get_accuracy(_attacker: Entity) -> float:
	var _learned_skill := _attacker.get_learned_skill(NAME)
	if not _learned_skill: return 0

	return _learned_skill.float_dict["chance_to_ignore_evasion"]