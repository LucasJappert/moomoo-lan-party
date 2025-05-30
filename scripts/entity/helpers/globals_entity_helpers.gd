class_name GlobalsEntityHelpers


static func is_target_in_attack_area(_entity: Entity, _target_entity) -> bool:
	if ObjectHelpers.is_null(_target_entity): return false

	var dist = _entity.global_position.distance_to(_target_entity.global_position)

	return dist <= _entity.combat_data.attack_range

static func get_nearest_entity_to_attack(my_owner: Entity, entities: Array[Entity]) -> Entity:
	var nearest_entity: Entity = null
	var closest_distance := INF

	for entity in entities:
		var dist = entity.global_position.distance_to(my_owner.global_position)
		if dist > my_owner.combat_data.attack_range: continue

		if dist < closest_distance:
			closest_distance = dist
			nearest_entity = entity

	return nearest_entity

static func roll_chance(_chance: float) -> bool:
	return randf() <= _chance