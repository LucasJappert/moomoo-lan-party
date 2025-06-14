class_name GlobalsEntityHelpers


static func is_target_in_attack_range(_entity: Entity, _target_entity) -> bool:
	if ObjectHelpers.is_null(_target_entity): return false

	var dist = _entity.global_position.distance_to(_target_entity.global_position)

	return dist <= _entity.combat_data.get_total_stats().attack_range

static func get_nearest_entity(start_pos: Vector2, entities: Array[Entity], max_range: int) -> Entity:
	var nearest_entity: Entity = null
	var closest_distance := INF

	for entity in entities:
		var dist = entity.global_position.distance_to(start_pos)
		if dist > max_range: continue

		if dist < closest_distance:
			closest_distance = dist
			nearest_entity = entity

	return nearest_entity

static func roll_chance(_chance: float) -> bool:
	return randf() <= _chance

static func get_owner(node: Node, max_depth: int = 10) -> Entity:
	var current := node.get_parent()
	var current_depth := 0
	while current != null and current_depth < max_depth:
		if current is Entity: return current
		current = current.get_parent()
		current_depth += 1
	return null

static func get_closest_entities(origin: Vector2, max_targets: int, entities: Array[Entity], max_distance: float = MapManager.TILE_SIZE_INT * 5) -> Array[Entity]:
	var sorted: Array[Entity] = []

	for entity in entities:
		var dist_sq := entity.global_position.distance_squared_to(origin)

		if max_distance >= 0.0 and dist_sq > max_distance * max_distance: continue # out of range

		sorted.append(entity)

	sorted.sort_custom(func(a: Entity, b: Entity) -> bool:
		return a.global_position.distance_squared_to(origin) < b.global_position.distance_squared_to(origin)
	)

	return sorted.slice(0, max_targets)
