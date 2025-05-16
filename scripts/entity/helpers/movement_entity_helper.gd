class_name MovementEntityHelper
var entity: Entity

func initialize(_entity: Entity):
	entity = _entity

func _server_move_along_path(_delta: float):
	if not entity.multiplayer.is_server():
		return

	if GlobalsEntityHelpers.is_target_entity_in_attack_area(entity):
		entity.current_path = []

	if entity.target_pos == null:
		if entity.current_path.is_empty():
			return _stop_movement()

		entity.current_cell = AStarGridManager.world_to_cell(entity.global_position)
		var next_target_cell = entity.current_path[0]

		
		if AStarGridManager.astar_grid.is_point_solid(next_target_cell):
			 # Update the path and return when next target cell is blocked
			entity._update_path()
			return _stop_movement()
		AStarGridManager.set_cell_blocked(entity.current_cell, false)
		AStarGridManager.set_cell_blocked(next_target_cell, true)
		entity.target_pos = AStarGridManager.cell_to_world(next_target_cell)
		entity.current_path.remove_at(0)

	entity.direction = (entity.target_pos - entity.global_position).normalized()
	entity.velocity = entity.direction * entity.mov_speed

	entity.global_position.x += entity.velocity.x * _delta
	entity.global_position.y += entity.velocity.y * _delta

	if entity.global_position.distance_to(entity.target_pos) < 2:
		entity.global_position = entity.target_pos
		entity.target_pos = null

func _stop_movement():
	entity.velocity = Vector2.ZERO
