class_name SkillUnbreakable

extends SkillBase

const NAME := "Unbreakable"
const ICON_SLOT := Vector2(7, 1)

const ANIMATION_RECT_REGION := Rect2(448, 576, 64, 64)
const FRAMES = 5

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	
	int_array = [100, 250, 300]
	float_array = [20, 18, 16]
	float_array1 = [6, 7, 8]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 7
		SKILLS[NAME].item_skill_base[i].create_effect = true
		SKILLS[NAME].item_skill_base[i].instant_use = true
		SKILLS[NAME].item_skill_base[i].mana_cost = int_array[i]
		SKILLS[NAME].item_skill_base[i].cooldown = float_array[i]
		SKILLS[NAME].item_skill_base[i].duration_in_seconds = float_array1[i]
		SKILLS[NAME].item_skill_base[i].description = "Grants complete immunity to all damage for " + StringHelpers.format_float(float_array1[i]) + " seconds."

static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false

	var skill := SkillUnbreakable.new(_learned_skill, true)
	_caster.add_active_skill(skill)

	# apply_animation(_my_owner, _learned_skill.duration_in_seconds)
	ShieldEffect.attach_to(_caster.front_animations_node, _learned_skill.duration_in_seconds)

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


static func actions_before_receive_damage(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	var _learned_skill := _target.get_learned_skill(NAME)

	return _target.get_learned_skill(NAME) != null
