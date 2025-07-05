class_name SkillArcLightningStorm

extends SkillBase

const ANIMATION_RECT_REGION := Rect2(0, 800, 64, 64)
const FRAMES = 12
const NAME = "Arc Lightning Storm"

var seconds_elapsed_from_last_strike: float = 0
var learned_skill: ItemSkillBase

func _init(_learned_skill: ItemSkillBase, _activate_on_start: bool = true):
	super._init(_learned_skill.my_name, _learned_skill.duration_in_seconds, _activate_on_start)
	learned_skill = _learned_skill

func process_skill(_owner: Entity, _delta: float) -> void:
	super.process_skill(_owner, _delta)
	if not active: return

	seconds_elapsed_from_last_strike += _delta
	if seconds_elapsed_from_last_strike < learned_skill.float_dict["interval"]: return

	seconds_elapsed_from_last_strike = 0
	_apply_strikes(_owner)

func _apply_strikes(_owner: Entity) -> void:
	var nearest_enemies := GlobalsEntityHelpers.get_closest_entities(_owner.global_position, 40, _owner.get_my_enemies(), learned_skill.range_in_tiles, [])
	if nearest_enemies.size() == 0: return

	var target: Entity = nearest_enemies[randi() % nearest_enemies.size()]
	SoundsHelper.play_electric()
	_apply_animation(target)
	var _di := DamageInfo.new(int(learned_skill.float_dict["damage_per_interval"]), learned_skill.damage_type, _owner.name)
	target.server_receive_damage(_di, _owner)
	target.apply_stun(learned_skill.float_dict["ministun_in_seconds"])


static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 8, _ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)

	int_array = [60, 80, 100]
	int_array1 = [120, 200, 320]
	float_array = [0.6, 0.5, 0.4]
	float_array1 = [0.8, 1, 1.2]
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].instant_use = true
		_SKILLS[NAME].item_skill_base[i].range_in_tiles = 5
		_SKILLS[NAME].item_skill_base[i].duration_in_seconds = 5
		_SKILLS[NAME].item_skill_base[i].float_dict["interval"] = float_array[i]
		_SKILLS[NAME].item_skill_base[i].float_dict["ministun_in_seconds"] = float_array1[i]
		_SKILLS[NAME].item_skill_base[i].float_dict["damage_per_interval"] = int_array[i]
		_SKILLS[NAME].item_skill_base[i].damage_type = DamageType.MAGIC
		_SKILLS[NAME].item_skill_base[i].mana_cost = int_array1[i]
		_SKILLS[NAME].item_skill_base[i].cooldown = 5
		_SKILLS[NAME].item_skill_base[i].description = "Calls down random lightning strikes on nearby enemies every " + StringHelpers.format_float(float_array[i]) + " seconds for 5 seconds, dealing " + StringHelpers.format_float(int_array[i]) + " magic damage and briefly stunning them for " + StringHelpers.format_float(float_array1[i]) + " seconds."

static func try_to_use(_my_owner: Entity, _learned_skill: ItemSkillBase) -> bool:
	if _learned_skill.my_name != NAME: return true

	var skill := SkillArcLightningStorm.new(_learned_skill, true)
	_my_owner.active_skills.append(skill)

	return true

static func _apply_animation(_target: Entity, _duration_in_seconds: float = 0) -> void:
	var frames = SpritesHelper.get_sprite_frames(
		ANIMATION_RECT_REGION.position,
		ANIMATION_RECT_REGION.size, FRAMES, 30, _duration_in_seconds > 0
	)

	var scale := Vector2(1.5, 1.5) if _target is Player else Vector2(1, 1)
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
