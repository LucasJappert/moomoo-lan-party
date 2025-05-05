extends Node2D

@onready var dynamic_nav_region: NavigationRegion2D = $DynamicObstacleRegion

func _ready():
	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_update_dynamic_navigation)
	_update_dynamic_navigation() # Llamada inicial

func _update_dynamic_navigation():
	var geometry := NavigationMeshSourceGeometryData2D.new()
	var obstacle_points := _add_moomoo_obstacle(geometry)
	_add_enemies_obstacles(geometry)
	_add_player_obstacle(geometry)

	# Usamos el polígono base ya existente
	var base_poly: NavigationPolygon = dynamic_nav_region.navigation_polygon
	NavigationServer2D.bake_from_source_geometry_data(base_poly, geometry)

	# Reasignamos (opcional)
	dynamic_nav_region.navigation_polygon = base_poly

	# Visualización de la navegación final
	var debug_nav_poly: Polygon2D
	if dynamic_nav_region.has_node("DebugNavArea"):
		debug_nav_poly = dynamic_nav_region.get_node("DebugNavArea") as Polygon2D
	else:
		debug_nav_poly = Polygon2D.new()
		debug_nav_poly.name = "DebugNavArea"
		dynamic_nav_region.add_child(debug_nav_poly)

	if base_poly.get_outline_count() > 0:
		debug_nav_poly.polygon = base_poly.get_outline(0)
	else:
		debug_nav_poly.polygon = PackedVector2Array()

	debug_nav_poly.color = Color(0, 1, 0, 0.3) # Verde semitransparente

	# Visualización de la obstrucción
	var debug_obstacle_poly: Polygon2D
	if dynamic_nav_region.has_node("DebugObstacle"):
		debug_obstacle_poly = dynamic_nav_region.get_node("DebugObstacle") as Polygon2D
	else:
		debug_obstacle_poly = Polygon2D.new()
		debug_obstacle_poly.name = "DebugObstacle"
		dynamic_nav_region.add_child(debug_obstacle_poly)

	debug_obstacle_poly.polygon = obstacle_points
	debug_obstacle_poly.color = Color(1, 0, 0, 0.3) # Rojo semitransparente  # Verde semitransparente

func _add_moomoo_obstacle(geometry: NavigationMeshSourceGeometryData2D) -> PackedVector2Array:
	var empty := PackedVector2Array()
	if GameManager.moomoo == null:
		return empty

	var margin_to_subtract := 10.0
	var radius = GameManager.moomoo.collision_shape.shape.radius - margin_to_subtract
	var center = GameManager.moomoo.global_position
	var points: PackedVector2Array = []
	var sides := 8

	for i in range(sides):
		var angle = TAU * float(i) / sides
		var point = center + Vector2(cos(angle), sin(angle)) * radius
		points.append(point)

	geometry.add_obstruction_outline(points)
	return points

func _add_enemies_obstacles(geometry: NavigationMeshSourceGeometryData2D) -> void:
	var margin_to_subtract := 10.0
	for enemy in GameManager.enemies_node.get_children():
		var shape = enemy.collision_shape.shape
		var radius = shape.radius - margin_to_subtract
		var center = enemy.global_position
		var points: PackedVector2Array = []
		var sides := 8

		for i in range(sides):
			var angle = TAU * float(i) / sides
			var point = center + Vector2(cos(angle), sin(angle)) * radius
			points.append(point)

		geometry.add_obstruction_outline(points)

func _add_player_obstacle(geometry: NavigationMeshSourceGeometryData2D) -> void:
	var margin_to_subtract := 10.0
	for player in GameManager.players.values():
		var shape = player.collision_shape.shape
		var radius = shape.radius - margin_to_subtract
		var center = player.global_position
		var points: PackedVector2Array = []
		var sides := 8

		for i in range(sides):
			var angle = TAU * float(i) / sides
			var point = center + Vector2(cos(angle), sin(angle)) * radius
			points.append(point)

		geometry.add_obstruction_outline(points)
