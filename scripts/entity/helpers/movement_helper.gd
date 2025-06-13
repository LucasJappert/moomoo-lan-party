class_name MovementHelper

var my_owner: Entity
var current_target_pos = null
var _target_entity: Entity
var _target_cell
var current_path: Array[Vector2i] = []
var current_cell = null
var _attack_mode_mode = false

func _init(p_owner: Entity):
	my_owner = p_owner

func _physics_process(_delta: float) -> void:
	if not GameManager.AM_I_HOST: return

	_try_to_move(_delta)

# region 	SETTERs
func clean_path() -> void:
	current_path = []

func set_attack_mode_mode(p_value: bool) -> void:
	_attack_mode_mode = p_value

func _stop_movements() -> void:
	current_target_pos = null
	my_owner.velocity = Vector2.ZERO
	_clean_movements()

func _clean_movements() -> void:
	_target_cell = null
	_target_entity = null
	current_path = []
	_attack_mode_mode = false

func set_target_entity(target: Entity) -> void:
	if target == _target_entity: return
	
	_clean_movements()

	if target == null: return

	_attack_mode_mode = true
	_target_entity = target
	update_path()

func set_target_cell(target_cell: Vector2i) -> void:
	_clean_movements()
	_target_cell = target_cell
	update_path()

func update_path() -> void:
	if _target_cell == null && _target_entity == null: return _clean_movements()

	var from_pos = current_target_pos if current_target_pos else my_owner.global_position
	var from_cell = MapManager.world_to_cell(from_pos)
	var target_cell = _target_cell if _target_cell else MapManager.world_to_cell(_target_entity.global_position)
	current_path = MapManager.find_path(from_cell, target_cell)

# endregion SETTERs

func _try_set_next_current_target_pos() -> void:
	update_path() # Intentamos recaucluar el path hacia el target, ya sea una entidad o una celda

	if current_path.is_empty(): return _clean_movements()

	if my_owner.combat_data.is_stunned(): return

	if _attack_mode_mode:
		var target_in_attack_range = GlobalsEntityHelpers.is_target_in_attack_range(my_owner, my_owner.combat_data.get_target_entity())
		if target_in_attack_range: return

	var next_target_cell = current_path[0]
	if MapManager._astar_grid.is_point_solid(next_target_cell): return

	MapManager.set_cell_blocked(MapManager.world_to_cell(my_owner.global_position), false)
	MapManager.set_cell_blocked(next_target_cell, true)
	current_target_pos = MapManager.cell_to_world(next_target_cell)
	current_path.remove_at(0)


func _try_to_move(_delta: float) -> void:
	# if _attack_mode_mode && GlobalsEntityHelpers.is_target_in_attack_range(my_owner, my_owner.combat_data.get_target_entity()):
	# 	_clean_movements()
	if current_target_pos == null: _try_set_next_current_target_pos()
	if current_target_pos == null: return _stop_movements()


	var old_distance = current_target_pos - my_owner.global_position
	var direction = old_distance.normalized()
	# TODO: get_total_stats en Entity
	var speed = my_owner.combat_data.get_total_stats().get_total_move_speed() * MapManager.TILE_SIZE.x
	var velocity = direction * speed

	var move_delta = velocity * _delta
	var new_pos = my_owner.global_position + move_delta

	# Detect if you went past the target
	var new_distance = current_target_pos - new_pos

	# If the sign of the dot product changes, you overshot
	if old_distance.dot(new_distance) <= 0.0:
		my_owner.global_position = current_target_pos
		current_target_pos = null

	my_owner.global_position = new_pos
	my_owner.direction = direction
	my_owner.velocity = velocity