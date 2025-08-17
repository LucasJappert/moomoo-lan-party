class_name SkillCleaveStrike
extends SkillBase

const NAME: String = "Cleave Strike"
const ICON_SLOT = Vector2(2, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.4, 0.5, 0.5]
	aux_array[1] = [1, 1, 2]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].target_to_enemy = false
		SKILLS[NAME].item_skill_base[i].set_cleave_percent(aux_array[0][i])
		SKILLS[NAME].item_skill_base[i].set_cleave_range(aux_array[1][i])
		SKILLS[NAME].item_skill_base[i].en_description = "Deals " + StringHelpers.format_percent(aux_array[0][i]) + " of the damage as a cleave effect to enemies behind the target for " + str(aux_array[1][i]) + " tiles."
		SKILLS[NAME].item_skill_base[i].es_description = "Inflige un " + StringHelpers.format_percent(aux_array[0][i]) + " del daño como efecto de tajo a los enemigos que estén detrás del objetivo en un área de " + str(aux_array[1][i]) + " tiles."
