class_name MovementHelper

var my_owner: Entity
var current_target_pos = null
var _target_entity: Entity
var _target_cell
var current_path: Array[Vector2i] = []
var _attack_move = false
var _can_move := true
var _last_current_path_update_time: float = - INF
var current_cell: Vector2i
const _NEXT_PATH_RECALC_MS = 1000

func _init(p_owner: Entity):
	my_owner = p_owner
	current_cell = MapManager.world_to_cell(my_owner.global_position)
	if my_owner is Moomoo: _can_move = false

func _physics_process(_delta: float) -> void:
	if GameManager.main_scene.PAUSED: return
	if my_owner.current_hp <= 0: return
	if not _can_move: return
	if not GameManager.AM_I_HOST: return
	if my_owner.is_spawning: return

	_try_to_update_target_from_latest_attacker()

	if current_target_pos == null: _try_set_next_current_target_pos()

	if current_target_pos == null and my_owner.velocity != Vector2.ZERO: _stop_movements()

	if current_target_pos: _try_to_move(_delta)

# region 	SETTERs
func clean_path() -> void:
	current_path = []

func set_attack_mode_mode(p_value: bool) -> void:
	_attack_move = p_value

func _stop_movements() -> void:
	current_target_pos = null
	my_owner.velocity = Vector2.ZERO
	_clean_movements()

func _clean_movements() -> void:
	_target_cell = null
	_target_entity = null
	current_path = []
	set_attack_mode_mode(false)

func set_target_entity(target: Entity) -> void:
	if target == _target_entity: return
	
	_clean_movements()

	if target == null: return

	set_attack_mode_mode(true)
	_target_entity = target
	update_path()

func set_target_cell(target_cell: Vector2i) -> void:
	if current_cell == target_cell: return
	_clean_movements()
	_target_cell = MapManager.get_safe_cell(target_cell)
	update_path()
	my_owner.register_attacker(null)

func update_path() -> void:
	if _target_cell == null && _target_entity == null: return

	# We do the following to update the current_path (useful for refreshing the path when an enemy has a tile blocked in the current path)
	if current_path.size() > 0:
		if Time.get_ticks_msec() - _last_current_path_update_time < _NEXT_PATH_RECALC_MS: return
		_last_current_path_update_time = Time.get_ticks_msec()

	var from_pos = current_target_pos if current_target_pos else my_owner.global_position
	var from_cell = MapManager.world_to_cell(from_pos)
	var target_cell = _target_cell if _target_cell != null else MapManager.world_to_cell(_target_entity.global_position)
	current_path = MapManager.find_path(from_cell, target_cell)

# endregion SETTERs

func _try_set_next_current_target_pos() -> void:
	update_path()

	if current_path.is_empty(): return _clean_movements()

	if my_owner.is_stunned: return

	if _attack_move:
		# Return if the target is in attack range (dont move, just attack)
		var target_in_attack_range = GlobalsEntityHelpers.is_target_in_attack_range(my_owner, my_owner.get_target_entity())
		if target_in_attack_range: return _clean_movements()

	if MapManager._astar_grid.is_point_solid(current_path[0]): return
	MapManager.set_cell_blocked(current_cell, false)
	current_cell = current_path[0]
	MapManager.set_cell_blocked(current_cell, true)
	
	current_target_pos = MapManager.cell_to_world(current_cell)
	current_path.remove_at(0)

func _try_to_update_target_from_latest_attacker():
	if my_owner.keep_ground: return
	if _target_cell or _target_entity: return
	if not my_owner.latest_attacker: return
	if my_owner is Player == false: return # Enemies should always have a target (Moomoo by default)

	# With the following logic, we ensure that our character moves towards the target (only if the target is out of attack range)
	if my_owner.get_target_entity():
		if GlobalsEntityHelpers.is_target_in_attack_range(my_owner, my_owner.get_target_entity()): return

	var nearest_enemy: Entity
	nearest_enemy = GlobalsEntityHelpers.get_nearest_entity(my_owner.global_position, GameManager.get_enemies(), my_owner.area_vision_shape.shape.radius)

	set_target_entity(nearest_enemy)
	my_owner.set_target_to_attack(nearest_enemy)

func _try_to_move(_delta: float) -> void:
	var old_distance = current_target_pos - my_owner.global_position
	var direction: Vector2 = old_distance.normalized()
	# TODO: get_total_stats en Entity
	var speed := my_owner.cache_total_stats.get_total_move_speed() * MapManager.TILE_SIZE.x
	var velocity := direction * speed

	var move_delta := velocity * _delta
	var new_pos := my_owner.global_position + move_delta

	# Detect if you went past the target
	var new_distance = current_target_pos - new_pos

	# If the sign of the dot product changes, you overshot
	if old_distance.dot(new_distance) <= 0.0:
		# my_owner.global_position = current_target_pos
		my_owner.global_position = MapManager.cell_to_world(MapManager.world_to_cell(current_target_pos))
		current_target_pos = null
		return

	my_owner.global_position = new_pos
	my_owner.direction = direction
	my_owner.velocity = velocity
