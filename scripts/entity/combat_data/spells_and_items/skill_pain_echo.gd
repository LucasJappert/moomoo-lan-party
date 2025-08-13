class_name SkillPainEcho
extends SkillBase

const NAME = "Pain Echo"
const ICON_SLOT = Vector2(10, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	
	aux_array[0] = [0.3, 0.4, 0.5] # precent reflected
	aux_array[1] = [100, 200, 300] # mana cost
	aux_array[2] = [8, 10, 12] # duration
	aux_array[3] = [18, 16, 14] # cooldown
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 7
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].create_effect = true
		SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[2][i]
		SKILLS[NAME].item_skill_base[i].cooldown = aux_array[3][i]
		SKILLS[NAME].item_skill_base[i].damage_type = DamageType.PURE
		SKILLS[NAME].item_skill_base[i].float_dict["percent_reflected"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].en_description = "Reflects " + StringHelpers.format_percent(aux_array[0][i]) + " of damage back to the attacker."
		SKILLS[NAME].item_skill_base[i].es_description = "Devuelve el " + StringHelpers.format_percent(aux_array[0][i]) + " del daño recibido al agresor."


static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if _di.was_reflected: return false
	if ObjectHelpers.is_null(_attacker): return false
	
	var skill_base := _target.get_active_skill(NAME)
	if not skill_base: return false

	var damage_to_reflect = maxi(1, roundi(_di.total_damage * skill_base.learned_skill.float_dict["percent_reflected"]))
	var _dtf := DamageInfo.new(damage_to_reflect, DamageType.PURE, _target.name)
	_dtf.was_reflected = true
	_attacker.server_receive_damage(_dtf, _target)

	return true

static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false

	var skill := SkillPainEcho.new(_learned_skill, true)
	if not _target.add_active_skill(skill): return false

	DamageReflectorEffect.remove_from(_caster.back_animations_node)
	DamageReflectorEffect.attach_to(_caster.back_animations_node, _learned_skill.duration_in_seconds)

	return true
