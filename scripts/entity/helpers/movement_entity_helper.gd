class_name MovementEntityHelper
var my_owner: Entity

func set_my_owner(_entity: Entity):
	my_owner = _entity

func _server_move_along_path(_delta: float):
	if not my_owner.multiplayer.is_server():
		return

	if GlobalsEntityHelpers.is_target_in_attack_area(my_owner, my_owner.target_entity):
		my_owner.current_path = []

	if my_owner.target_pos == null:
		if my_owner.current_path.is_empty():
			return _stop_movement()

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

	my_owner.direction = (my_owner.target_pos - my_owner.global_position).normalized()
	my_owner.velocity = my_owner.direction * my_owner.mov_speed

	my_owner.global_position.x += my_owner.velocity.x * _delta
	my_owner.global_position.y += my_owner.velocity.y * _delta

	if my_owner.global_position.distance_to(my_owner.target_pos) < 2:
		my_owner.global_position = my_owner.target_pos
		my_owner.target_pos = null

func _stop_movement():
	my_owner.velocity = Vector2.ZERO
