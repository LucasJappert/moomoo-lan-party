class_name GlobalsEntityHelpers

static func get_nearest_enemy_inside_vision(_owner: Entity) -> Entity:
	var result: Entity
	var closest_distance := INF

	for enemy in _owner.get_my_enemies():
		if enemy.is_dying: continue
		var dist = _owner.global_position.distance_to(enemy.global_position)
		if dist > _owner.vision_helper.radius: continue
		if dist >= closest_distance: continue

		closest_distance = dist
		result = enemy

	return result

static func is_target_in_attack_range(_origin: Entity, _target) -> bool:
	if ObjectHelpers.is_null(_target): return false

	var dist = _origin.global_position.distance_to(_target.global_position)

	return dist <= _origin.cache_total_stats.get_attack_range()

static func get_nearest_entity(start_pos: Vector2, entities: Array[Entity], max_range: int) -> Entity:
	var nearest_entity: Entity = null
	var closest_distance := INF

	for entity in entities:
		if entity.is_dying: continue
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
	entities: Array[Entity],
	max_distance_in_tiles: float = 5.0,
	max_targets: int = 100,
	excluded_entities: Array[Entity] = []
) -> Array[Entity]:
	var sorted: Array[Entity] = []

	var origin_tile := MapManager.world_to_cell(origin)

	for entity in entities:
		if entity.current_hp <= 0: continue
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

static func filter_enemies_according_to_caster_direction(
	attacker_pos: Vector2,
	target_pos: Vector2,
	enemies: Array[Entity],
	angle_threshold_deg: float = 90.0
) -> Array[Entity]:
	var attacker_cell := MapManager.world_to_cell(attacker_pos)
	var target_cell := MapManager.world_to_cell(target_pos)

	# Dirección redondeada a una de las 8
	var attack_dir := ObjectHelpers.get_snapped_8_direction(Vector2(target_cell - attacker_cell)).normalized()

	var result: Array[Entity] = []

	for enemy in enemies:
		if not is_instance_valid(enemy): continue

		var enemy_cell := MapManager.world_to_cell(enemy.global_position)
		var to_enemy_vector := Vector2(enemy_cell - target_cell)

		if to_enemy_vector == Vector2.ZERO:
			continue

		var to_enemy_dir := ObjectHelpers.get_snapped_8_direction(to_enemy_vector).normalized()

		# Usamos dot product + acos para obtener el ángulo en grados
		var dot = clamp(attack_dir.dot(to_enemy_dir), -1.0, 1.0)
		var angle_deg := rad_to_deg(acos(dot))

		if angle_deg <= angle_threshold_deg:
			result.append(enemy)

	return result


static func print_description_skills(entity: Entity) -> void:
	for skill in entity._skills:
		for skill_base in skill.item_skill_base:
			print(skill.get_description())

static func grants_random_skills(entity: Entity, learned_level: int = 1) -> void:
	entity._skills = []
	var available_skills: Array[Skill] = SkillBase.SKILLS.values()
	for i in range(1, 5):
		var random_skill := available_skills[randi_range(0, available_skills.size() - 1)]
		
		entity._skills.append(SkillBase.get_new_learned_skill(random_skill.get_name(), min(3, learned_level)))

		if available_skills.size() <= 0: continue
		available_skills.erase(random_skill)