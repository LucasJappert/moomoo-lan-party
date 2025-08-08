class_name SkillShieldedCore

extends SkillBase

const ANIMATION_RECT_REGION := Rect2(0, 992, 64, 96)
const NAME = "Shielded Core"
const ICON_SLOT = Vector2(0, 0)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	
	aux_array[0] = [0.3, 0.4, 0.5] # precent defense
	aux_array[1] = [60, 80, 100] # mana cost
	aux_array[2] = [8, 6, 4] # cooldown
	aux_array[3] = [12, 15, 18] # duration
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 7
		SKILLS[NAME].item_skill_base[i].create_effect = true
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].set_physical_defense_percent(aux_array[0][i])
		SKILLS[NAME].item_skill_base[i].set_magic_defense_percent(aux_array[0][i])
		SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].cooldown = aux_array[2][i]
		SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[3][i]
		SKILLS[NAME].item_skill_base[i].en_description = "Grants " + StringHelpers.format_percent(aux_array[0][i]) + " physical and magic defense for " + StringHelpers.format_float(aux_array[3][i]) + " seconds."
		SKILLS[NAME].item_skill_base[i].es_description = "Otorga un " + StringHelpers.format_percent(aux_array[0][i]) + " de defensa física y mágica durante " + StringHelpers.format_float(aux_array[3][i]) + " segundos."


static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false

	var new_effect = CombatEffect.get_effect_from_item_skill_base(_learned_skill, SKILLS[NAME].region_rect)
	new_effect.set_description(_learned_skill.en_description)
	new_effect.set_region_rect(SkillBase.SKILLS[_learned_skill.my_name].region_rect)
	_target.effects_helper.add_effect(new_effect)

	ShieldOrbitEffect.attach_to(_target.front_animations_node, _learned_skill.duration_in_seconds)

	return true
