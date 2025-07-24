class_name SkillManaScorcher
extends SkillBase

const NAME = "Mana Scorcher"
const ICON_SLOT = Vector2(4, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.5, 0.75, 1] # Percentage of mana to burn regarding physical damage dealt
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 0
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].float_dict[CombatStats.PERCENT_MANA_TO_BURN] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].description = "Burns mana from the target equal to " + StringHelpers.format_percent(aux_array[0][i]) + " of the physical damage dealt, and deals physical damage equivalent to the mana burned."

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if _di.was_reflected or _di.was_a_cleave_damage or _di.temporal_damage: return false
	if _di.damage_type != DamageType.PHYSICAL: return false

	var _learned_skill := _attacker.get_learned_skill(NAME)
	if not _learned_skill: return false

	var burned_mana: int = _di.total_damage * _learned_skill.float_dict[CombatStats.PERCENT_MANA_TO_BURN]
	if burned_mana <= 0: return false

	_target.update_current_mana(-burned_mana)

	_di.total_damage += burned_mana

	return true