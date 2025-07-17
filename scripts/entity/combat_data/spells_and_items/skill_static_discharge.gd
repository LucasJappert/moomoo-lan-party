class_name SkillStaticDischarge

extends SkillBase

const NAME = "Static Discharge"
const ANIMATION_RECT_REGION := Rect2(64, 992, 64, 96)
const FRAMES = 14

const SKILL_NAMES_TRIGGERING_DISCHARGE: Array[String] = [
	SkillArcLightningStorm.NAME,
	SkillShockSpear.NAME,
	SkillStormWrath.NAME
]

static func actions_after_cast_skill(_owner: Entity, _skill_used: ItemSkillBase) -> void:
	if not SKILL_NAMES_TRIGGERING_DISCHARGE.has(_skill_used.my_name): return

	for skill in _owner.get_skills():
		var _learned_skill = skill.get_learned_skill()
		if not _learned_skill: continue
		if _learned_skill.my_name != NAME: continue
		_apply_strikes(_owner, _learned_skill)

static func _apply_strikes(_owner: Entity, _learned_skill: ItemSkillBase) -> void:
	var nearest_enemies := GlobalsEntityHelpers.get_closest_entities(_owner.global_position, 30, _owner.get_my_enemies(), _learned_skill.effect_radius_in_tiles)
	for enemy in nearest_enemies:
		var magic_damage: int = enemy.get_total_hp() * _learned_skill.float_dict["percent_damage_from_max_hp"]

		var total_magic_damage = _owner.get_total_magic_damage(magic_damage)
		var _di := DamageInfo.new(total_magic_damage, _learned_skill.damage_type, _owner.name)
		enemy.server_receive_damage(_di, _owner)
	
static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 10, _ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)
	
	aux_array[0] = [0.05, 0.06, 0.07]
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].instant_use = true
		_SKILLS[NAME].item_skill_base[i].effect_radius_in_tiles = 7
		_SKILLS[NAME].item_skill_base[i].float_dict["percent_damage_from_max_hp"] = 0.05
		_SKILLS[NAME].item_skill_base[i].damage_type = DamageType.MAGIC
		_SKILLS[NAME].item_skill_base[i].description = "Each time the hero casts a skill, nearby enemies are electrified, taking magic damage equal to " + StringHelpers.format_percent(aux_array[0][i]) + " of their max HP."