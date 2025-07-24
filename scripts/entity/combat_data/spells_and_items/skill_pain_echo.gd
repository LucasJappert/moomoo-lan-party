class_name SkillPainEcho
extends SkillBase

const NAME = "Pain Echo"
const ICON_SLOT = Vector2(10, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	
	aux_array[0] = [0.1, 0.15, 0.2] # precent reflected
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 0
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].create_effect = true
		SKILLS[NAME].item_skill_base[i].damage_type = DamageType.PURE
		SKILLS[NAME].item_skill_base[i].float_dict["percent_reflected"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].description = "Reflects " + StringHelpers.format_percent(aux_array[0][i]) + " of damage back to the attacker."

		
static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if _di.was_reflected or _di.was_a_cleave_damage or _di.temporal_damage: return false
	
	var _learned_skill = _target.get_learned_skill(NAME)
	if not _learned_skill: return false

	var damage_to_reflect = maxi(1, roundi(_di.total_damage * _learned_skill.float_dict["percent_reflected"]))
	var _dtf := DamageInfo.new(damage_to_reflect, DamageType.PURE, _target.name)
	_dtf.was_reflected = true
	_attacker.server_receive_damage(_dtf, _target)

	return true

static func on_active_skill_added(_owner: Entity, _skill: SkillBase) -> void:
	if _skill.my_name != NAME: return

	var effect_node = DamageReflectorEffect.attach_to(_owner.back_animations_node)
	effects_running_by_owner_name[_owner.name] = effect_node

static func on_active_skill_removed(_owner: Entity, _skill: SkillBase) -> void:
	if _skill.my_name != NAME: return

	if effects_running_by_owner_name.has(_owner.name):
		effects_running_by_owner_name[_owner.name].queue_free()
		effects_running_by_owner_name.erase(_owner.name)
