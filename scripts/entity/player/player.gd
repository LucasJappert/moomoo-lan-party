class_name Player

extends Entity

@export var player_id: int = 0
@export var current_exp: int = 0
@export var current_level: int = 1
const MAX_LEVEL: int = 30
static var _EXP_PER_LEVEL: Dictionary[int, int] = {}

func set_player_id(value: int) -> void:
	player_id = value

func get_client_inputs(): return %ClientInputs

func _ready():
	super._ready()
	global_position = MapManager.cell_to_world(MapManager.PLAYER_CELL_SPAWN)
	combat_data.max_hp = 5000
	combat_data.current_hp = 5000
	combat_data.attack_type = AttackTypes.RANGED
	combat_data.attack_range = 300
	combat_data.attack_speed = 200
	combat_data.crit_chance = 0.5
	combat_data.physical_attack_power = 100
	combat_data.projectile_type = Projectile.TYPES.ARROW
	combat_data.move_speed = 5
	combat_data.skills.append_array([
		Skill.get_shielded_core(),
		Skill.get_lifesteal(),
		# Skill.get_frozen_touch(),
		# Skill.get_stunning_strike()s
	])

	# We need to update the radius of the attack area node here as it enters the scene
	_set_area_attack_shape_radius()

	if player_id == multiplayer.get_unique_id():
		MyCamera.update_camera_position(global_position)
		Main.MY_PLAYER = self

func _update_path(_target_cell: Vector2i):
	var from_cell = MapManager.world_to_cell(target_pos if target_pos != null else global_position)
	current_path = MapManager.find_path(from_cell, _target_cell)

# region 	SETTERs
func increment_current_exp(value: int) -> void:
	current_exp += value

	while current_level < MAX_LEVEL:
		var exp_needed := get_exp_per_level(current_level)
		if current_exp < exp_needed: break
		current_exp -= exp_needed
		current_level += 1
		print("🎉✨ LEVEL UP! You've reached Level %d! 🚀🔥" % current_level)

	# If the maximum level is reached, cap the experience
	if current_level >= MAX_LEVEL:
		current_level = MAX_LEVEL
		current_exp = min(current_exp, get_exp_per_level(current_level))

# endregion SETTERs

static func get_exp_per_level(level: int) -> int:
	if not _EXP_PER_LEVEL.is_empty(): return _EXP_PER_LEVEL[level]

	for i in range(1, MAX_LEVEL + 1):
		_EXP_PER_LEVEL[i] = int(floor(100 * pow(i, 1.5)))
	print(_EXP_PER_LEVEL)

	return _EXP_PER_LEVEL[level]

static func get_total_accumulated_exp() -> int:
	var total_exp = 0
	for i in range(1, MAX_LEVEL + 1):
		total_exp += get_exp_per_level(i)
	return total_exp
