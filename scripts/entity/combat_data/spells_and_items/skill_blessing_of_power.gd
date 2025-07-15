class_name SkillBlessingOfPower
extends SkillBase

const NAME = "Blessing of Power"
const ICON_SLOT = Vector2(1, 0)

static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	
	aux_array[0] = [0.3, 0.4, 0.5]
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].stats.physical_attack_power_percent = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].stats.magic_attack_power_percent = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].stats.is_owner_friendly = true
		_SKILLS[NAME].item_skill_base[i].max_stacks = 1
		_SKILLS[NAME].item_skill_base[i].apply_to_owner = true
		_SKILLS[NAME].item_skill_base[i].create_effect = true
		aux_array[1] = StringHelpers.format_percent(_SKILLS[NAME].item_skill_base[i].stats.physical_attack_power_percent)
		_SKILLS[NAME].item_skill_base[i].description = "Increases physical and magic attack power by " + aux_array[1]

static func try_add_effect_from_skill(_owner: Entity, _skill: Skill) -> bool:
	if _skill.get_name() != NAME: return false
	if not _skill.get_learned_skill(): return false

	_owner.effects_helper.remove_effect_by_name(NAME)

	var new_effect = CombatEffect.get_permanent_effect_from_skill(_skill)
	_owner.effects_helper.add_effect(new_effect)

	return true
