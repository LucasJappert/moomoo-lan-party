class_name SkillTrueStrike
extends SkillBase

const NAME = "True Strike"
const ICON_SLOT = Vector2(3, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.4, 0.7, 1]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].set_chance_to_ignore_evasion(aux_array[0][i])
		SKILLS[NAME].item_skill_base[i].en_description = "Grants " + StringHelpers.format_percent(aux_array[0][i]) + " chance to ignore the target's evasion."
		SKILLS[NAME].item_skill_base[i].es_description = "Otorga un " + StringHelpers.format_percent(aux_array[0][i]) + " de probabilidad de ignorar la evasión del objetivo."
