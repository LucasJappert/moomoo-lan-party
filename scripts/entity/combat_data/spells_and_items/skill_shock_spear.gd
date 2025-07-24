class_name SkillShockSpear

extends SkillBase

const ANIMATION_RECT_REGION := Rect2(0, 992, 64, 96)
const FRAMES = 14
const NAME = "Shock Spear"

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * 8, ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [60, 100, 140] # magic_damage
	aux_array[1] = [120, 200, 320] # mana cost
	aux_array[2] = [8, 6, 4] # cooldown
	aux_array[3] = [1, 1.5, 2] # stun_duration
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].instant_use = false
		SKILLS[NAME].item_skill_base[i].area_of_effect_in_tiles = 7
		SKILLS[NAME].item_skill_base[i].float_dict["stun_radius"] = 1
		SKILLS[NAME].item_skill_base[i].float_dict["magic_damage"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].float_dict["stun_duration"] = aux_array[3][i]
		SKILLS[NAME].item_skill_base[i].damage_type = DamageType.MAGIC
		SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].cooldown = aux_array[2][i]
		SKILLS[NAME].item_skill_base[i].description = "Calls down a lightning strike on a target enemy, dealing " + StringHelpers.format_float(aux_array[0][i]) + " magic damage and stunning them and nearby enemies for " + StringHelpers.format_float(aux_array[3][i]) + " seconds."

static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false

	apply_strike(_caster, _target, _learned_skill)

	return true
	
static func apply_strike(_owner: Entity, _target: Entity, _learned_skill: ItemSkillBase) -> void:
	_apply_animation(_target)
	SoundsHelper.play_electric_1()

	var total_magic_damage = _owner.get_total_magic_damage(_learned_skill.float_dict["magic_damage"])
	var _di := DamageInfo.new(total_magic_damage, _learned_skill.damage_type, _owner.name)
	_target.server_receive_damage(_di, _owner)

	var enemies_to_stun := GlobalsEntityHelpers.get_closest_entities(_target.position, _owner.get_my_enemies(), _learned_skill.float_dict["stun_radius"])
	for _enemy in enemies_to_stun:
		_enemy.apply_stun(_learned_skill.float_dict["stun_duration"])

static func _apply_animation(_target: Entity) -> void:
	var frames = SpritesHelper.get_sprite_frames(
		ANIMATION_RECT_REGION.position,
		ANIMATION_RECT_REGION.size, FRAMES, 20, false
	)

	var scale := Vector2(1.5, 1.5) if _target is Player else Vector2(1, 1)
	var anim_position = AnimationsHelper.get_position_of_bottom_of_the_cell(ANIMATION_RECT_REGION.size)
	if scale.y != 1:
		anim_position.y = anim_position.y - ANIMATION_RECT_REGION.size.y * 0.5 * (scale.y - 1)

	var sprite := AnimationsHelper.spawn_front_animation(_target, frames, NAME, anim_position)
	sprite.scale = scale
