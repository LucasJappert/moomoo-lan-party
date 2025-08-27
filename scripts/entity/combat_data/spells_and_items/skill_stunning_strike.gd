class_name SkillStunningStrike

extends SkillBase

const NAME = "Stunning Strike"
const ICON_SLOT = Vector2(4, 0)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.15, 0.2, 0.25]
	var chances_for_ranged := [aux_array[0][0] * 0.5, aux_array[0][1] * 0.5, aux_array[0][2] * 0.5]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].set_stun_chance(aux_array[0][i])
		SKILLS[NAME].item_skill_base[i].add_debuff(CombatStats.DEBUFF_KEY_RANGED_UNITS, CombatStats.STUN_CHANCE, -chances_for_ranged[i])
		SKILLS[NAME].item_skill_base[i].set_stun_duration(2)
		SKILLS[NAME].item_skill_base[i].en_description = "Has a " + StringHelpers.format_percent(aux_array[0][i]) + " (" + StringHelpers.format_percent(chances_for_ranged[i]) + " for ranged attacks) chance to stun the target for 2 seconds."
		SKILLS[NAME].item_skill_base[i].es_description = "Tiene un " + StringHelpers.format_percent(aux_array[0][i]) + " (" + StringHelpers.format_percent(chances_for_ranged[i]) + " para ataques a distancia) de probabilidad de aturdir al objetivo durante 2 segundos."
