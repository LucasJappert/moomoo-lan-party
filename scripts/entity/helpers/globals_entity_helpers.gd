class_name GlobalsEntityHelpers


static func is_target_in_attack_range(_entity: Entity, _target_entity) -> bool:
	if ObjectHelpers.is_null(_target_entity): return false

	var dist = _entity.global_position.distance_to(_target_entity.global_position)

	return dist <= _entity.combat_data.cache_total_stats.attack_range

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

static func get_closest_entities(
	origin: Vector2,
	max_targets: int,
	entities: Array[Entity],
	max_distance_in_tiles: float = 5.0,
	excluded_entities: Array[Entity] = []
) -> Array[Entity]:
	var sorted: Array[Entity] = []

	var origin_tile := MapManager.world_to_cell(origin)

	for entity in entities:
		if entity in excluded_entities:
			continue

		var entity_tile := MapManager.world_to_cell(entity.global_position)
		var tile_offset := entity_tile - origin_tile
		var distance_in_tiles := tile_offset.length() # euclidiana entre tiles

		if max_distance_in_tiles >= 0 and distance_in_tiles > max_distance_in_tiles:
			continue

		sorted.append(entity)

	sorted.sort_custom(func(a: Entity, b: Entity) -> bool:
		var a_dist := (MapManager.world_to_cell(a.global_position) - origin_tile).length_squared()
		var b_dist := (MapManager.world_to_cell(b.global_position) - origin_tile).length_squared()
		return a_dist < b_dist
	)

	return sorted.slice(0, max_targets)


static func print_description_skills(entity: Entity) -> void:
	for skill in entity.combat_data._skills:
		for skill_base in skill.item_skill_base:
			print(skill.get_description())
