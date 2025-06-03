class_name MovementEntityHelper
var my_owner: Entity

func set_my_owner(_entity: Entity):
	my_owner = _entity

static func clean_path(_entity: Entity) -> void:
	_entity.current_path = []

func _server_move_along_path(_delta: float) -> void:
	if not my_owner.multiplayer.is_server(): return

	if GlobalsEntityHelpers.is_target_in_attack_area(my_owner, my_owner.target_entity):
		my_owner.current_path = []

	if my_owner.target_pos == null:
		if my_owner.combat_data.is_stunned(): return
		
		if my_owner.current_path.is_empty(): return _stop_movement()

		my_owner.current_cell = MapManager.world_to_cell(my_owner.global_position)
		var next_target_cell = my_owner.current_path[0]

		if MapManager._astar_grid.is_point_solid(next_target_cell):
			 # Update the path and return when next target cell is blocked
			my_owner._update_path(my_owner.current_path.back())
			return _stop_movement()
		MapManager.set_cell_blocked(my_owner.current_cell, false)
		MapManager.set_cell_blocked(next_target_cell, true)
		my_owner.target_pos = MapManager.cell_to_world(next_target_cell)
		my_owner.current_path.remove_at(0)

	var to_target = my_owner.target_pos - my_owner.global_position
	var direction = to_target.normalized()
	var speed = my_owner.combat_data.get_total_stats().move_speed * MapManager.TILE_SIZE.x
	var velocity = direction * speed

	var move_delta = velocity * _delta
	var new_pos = my_owner.global_position + move_delta

	# Detect if you went past the target
	var old_to_target = my_owner.target_pos - my_owner.global_position
	var new_to_target = my_owner.target_pos - new_pos

	# If the sign of the dot product changes, you overshot
	if old_to_target.dot(new_to_target) <= 0.0:
		my_owner.global_position = my_owner.target_pos
		my_owner.target_pos = null
	else:
		my_owner.global_position = new_pos

	my_owner.direction = direction
	my_owner.velocity = velocity

func _stop_movement() -> void:
	my_owner.velocity = Vector2.ZERO
