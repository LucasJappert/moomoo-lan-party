class_name SkillTrueStrike
extends SkillBase

const NAME = "True Strike"
const ICON_SLOT = Vector2(3, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.4, 0.7, 1]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 0
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].float_dict[CombatStats.CHANCE_TO_IGNORE_EVASION] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].description = "Grants " + StringHelpers.format_percent(aux_array[0][i]) + " chance to ignore the target's evasion."

static func roll_true_strike(_di: DamageInfo, _attacker: Entity) -> float:
	if _di.damage_type != DamageType.PHYSICAL: return false # Ignore enemy evasion only for physical damage

	var _learned_skill := _attacker.get_learned_skill(NAME)
	if not _learned_skill: return 0

	var attacker_accuracy: float = _learned_skill.float_dict[CombatStats.CHANCE_TO_IGNORE_EVASION]

	return GlobalsEntityHelpers.roll_chance(attacker_accuracy)