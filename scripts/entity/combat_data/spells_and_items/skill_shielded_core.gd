class_name SkillShieldedCore

extends SkillBase


const ANIMATION_RECT_REGION := Rect2(0, 992, 64, 96)
const FRAMES = 14
const NAME = "Shielded Core"
const ICON_SLOT = Vector2(0, 0)

static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	
	aux_array[0] = [0.3, 0.4, 0.5] # precent defense
	aux_array[1] = [60, 80, 100] # mana cost
	aux_array[2] = [8, 6, 4] # cooldown
	aux_array[3] = [12, 15, 18] # duration
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].create_effect = true
		_SKILLS[NAME].item_skill_base[i].stats.is_owner_friendly = true
		_SKILLS[NAME].item_skill_base[i].stats.physical_defense_percent = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].stats.magic_defense_percent = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[1][i]
		_SKILLS[NAME].item_skill_base[i].cooldown = aux_array[2][i]
		_SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[3][i]
		_SKILLS[NAME].item_skill_base[i].description = "Grants " + StringHelpers.format_percent(aux_array[0][i]) + " physical and magic defense for " + StringHelpers.format_float(aux_array[3][i]) + " seconds."

static func try_to_use(_my_owner: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return true

	var new_effect = CombatEffect.get_temporal_effect(NAME, _learned_skill.duration_in_seconds, _learned_skill.max_stacks, _learned_skill.stats)
	new_effect.set_description(_learned_skill.description)
	new_effect.set_region_rect(Skill._SKILLS[_learned_skill.my_name].region_rect)
	_target.effects_helper.add_effect(new_effect)

	ShieldOrbitEffect.attach_to(_target.front_animations_node, _learned_skill.duration_in_seconds)

	return true
