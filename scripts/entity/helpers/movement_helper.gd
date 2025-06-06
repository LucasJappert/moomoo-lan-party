class_name MovementHelper

extends Node2D

var my_owner: Entity
var target_pos = null
var target_entity: Entity
var current_path: Array[Vector2i] = []
var current_cell = null

func _init(p_owner: Entity):
	my_owner = p_owner

func clean_path() -> void:
	current_path = []

func update_path(_target_cell: Vector2i):
	var from_pos = target_pos if target_pos != null else my_owner.global_position
	var from_cell = MapManager.world_to_cell(from_pos)
	current_path = MapManager.find_path(from_cell, _target_cell)

func server_move_along_path(_delta: float) -> void:
	if not my_owner.multiplayer.is_server(): return

	if GlobalsEntityHelpers.is_target_in_attack_area(my_owner, target_entity):
		current_path = []

	if target_pos == null:
		if my_owner.combat_data.is_stunned(): return
		
		if current_path.is_empty(): return _stop_movement()

		current_cell = MapManager.world_to_cell(my_owner.global_position)
		var next_target_cell = current_path[0]

		if MapManager._astar_grid.is_point_solid(next_target_cell):
			 # Update the path and return when next target cell is blocked
			update_path(current_path.back())
			return _stop_movement()
		MapManager.set_cell_blocked(current_cell, false)
		MapManager.set_cell_blocked(next_target_cell, true)
		target_pos = MapManager.cell_to_world(next_target_cell)
		current_path.remove_at(0)

	var old_distance = target_pos - my_owner.global_position
	var direction = old_distance.normalized()
	# TODO: get_total_stats en Entity
	var speed = my_owner.combat_data.get_total_stats().move_speed * MapManager.TILE_SIZE.x
	var velocity = direction * speed

	var move_delta = velocity * _delta
	var new_pos = my_owner.global_position + move_delta

	# Detect if you went past the target
	var new_distance = target_pos - new_pos

	# If the sign of the dot product changes, you overshot
	if old_distance.dot(new_distance) <= 0.0:
		my_owner.global_position = target_pos
		target_pos = null
	else:
		my_owner.global_position = new_pos

	my_owner.direction = direction
	my_owner.velocity = velocity

func _stop_movement() -> void:
	my_owner.velocity = Vector2.ZERO

func try_set_current_path_for_enemy(player: Entity):
	target_entity = player

	if target_entity == null: target_entity = GameManager.moomoo

	if target_entity == null: return

	if GlobalsEntityHelpers.is_target_in_attack_area(my_owner, target_entity):
		current_path = []
		return

	var from_cell = MapManager.world_to_cell(target_pos if target_pos != null else my_owner.global_position)
	var to_cell = MapManager.world_to_cell(target_entity.global_position)
	current_path = MapManager.find_path(from_cell, to_cell)
