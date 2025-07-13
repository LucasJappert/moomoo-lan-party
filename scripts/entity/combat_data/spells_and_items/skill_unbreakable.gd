class_name SkillUnbreakable

extends SkillBase

const ANIMATION_RECT_REGION := Rect2(448, 576, 64, 64)
const FRAMES = 5
const NAME = Skill.Names.UNBREAKABLE

static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	const _skill_name = Skill.Names.UNBREAKABLE
	_SKILLS[_skill_name] = Skill.new(_skill_name, SkillType.ACTIVE)
	_SKILLS[_skill_name].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 7, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	
	int_array = [100, 250, 300]
	float_array = [20, 18, 16]
	float_array1 = [6, 7, 8]
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[_skill_name].item_skill_base[i].create_effect = true
		_SKILLS[_skill_name].item_skill_base[i].instant_use = true
		_SKILLS[_skill_name].item_skill_base[i].mana_cost = int_array[i]
		_SKILLS[_skill_name].item_skill_base[i].cooldown = float_array[i]
		_SKILLS[_skill_name].item_skill_base[i].duration_in_seconds = float_array1[i]
		_SKILLS[_skill_name].item_skill_base[i].description = "Grants complete immunity to all damage for " + StringHelpers.format_float(float_array1[i]) + " seconds."

static func try_to_use(_my_owner: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != Skill.Names.UNBREAKABLE: return true

	var skill := SkillUnbreakable.new(_learned_skill, true)
	_my_owner.add_active_skill(skill)

	# apply_animation(_my_owner, _learned_skill.duration_in_seconds)
	ShieldEffect.attach_to(_my_owner.front_animations_node, _learned_skill.duration_in_seconds)

	return true

static func apply_animation(_target: Entity, _duration_in_seconds: float = 0) -> void:
	var frames = SpritesHelper.get_sprite_frames(
		ANIMATION_RECT_REGION.position,
		ANIMATION_RECT_REGION.size, FRAMES, 20, _duration_in_seconds > 0
	)

	var scale := Vector2(2, 2) if _target is Player else Vector2(1, 1)
	var anim_position = AnimationsHelper.get_position_of_bottom_of_the_cell(ANIMATION_RECT_REGION.size)
	if scale.y != 1:
		anim_position.y = anim_position.y - ANIMATION_RECT_REGION.size.y * 0.5 * (scale.y - 1)

	var sprite := AnimationsHelper.spawn_front_animation(_target, frames, NAME, anim_position)
	sprite.scale = scale

	if _duration_in_seconds == 0: return

	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = _duration_in_seconds
	timer.autostart = true
	sprite.add_child(timer)
	timer.timeout.connect(func(): sprite.queue_free())
