class_name MapManager

const TILE_SIZE: Vector2 = Vector2(32, 32)
const PLAYER_CELL_SPAWN: Vector2i = Vector2i(20, 12)

const grid_width: int = 56
const grid_height: int = 44
const grid_origin: Vector2i = Vector2i(-8, -12)

static var _astar_grid: AStarGrid2D = AStarGrid2D.new()


static func initialize():
	_astar_grid.region = Rect2i(grid_origin, Vector2i(grid_width, grid_height))
	_astar_grid.cell_size = TILE_SIZE
	_astar_grid.offset = Vector2(grid_origin.x * TILE_SIZE.x, grid_origin.y * TILE_SIZE.y) # ← 🔥 clave
	_astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES

	_astar_grid.update()

	for y in range(grid_origin.y, grid_origin.y + grid_height):
		for x in range(grid_origin.x, grid_origin.x + grid_width):
			var cell = Vector2i(x, y)
			_astar_grid.set_point_solid(cell, false)

static func find_nearest_valid_point(target: Vector2i) -> Vector2i:
	var closest_point := Vector2i.ZERO
	var min_distance := INF

	for y in range(grid_origin.y, grid_origin.y + grid_height):
		for x in range(grid_origin.x, grid_origin.x + grid_width):
			var point := Vector2i(x, y)
			if _astar_grid.is_point_solid(point):
				continue

			var dist := target.distance_squared_to(point)
			if dist < min_distance:
				min_distance = dist
				closest_point = point

	return closest_point

static func find_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	if not _astar_grid.is_in_boundsv(start): return []

	# Adjust the destination point if it is out of the grid
	if not _astar_grid.is_in_boundsv(end):
		end = find_nearest_valid_point(end)

	var path: Array[Vector2i] = _astar_grid.get_id_path(start, end, true)
	if path.is_empty():
		return []
		
	path.remove_at(0) # Remove start from path
	return path

static func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / TILE_SIZE.x), floor(pos.y / TILE_SIZE.y))

static func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE_SIZE.x + TILE_SIZE.x / 2, cell.y * TILE_SIZE.y + TILE_SIZE.y / 2)
	
static func cell_to_world_2i(cell: Vector2i) -> Vector2i:
	return Vector2i(int(cell.x * TILE_SIZE.x + TILE_SIZE.x / 2), int(cell.y * TILE_SIZE.y + TILE_SIZE.y / 2))
	
static func set_cell_blocked(cell: Vector2i, blocked: bool):
	if _astar_grid.is_in_boundsv(cell):
		_astar_grid.set_point_solid(cell, blocked)
		
static func set_cell_blocked_from_world(pos: Vector2, blocked: bool):
	set_cell_blocked(world_to_cell(pos), blocked)

static func is_cell_blocked(cell: Vector2i) -> bool:
	return _astar_grid.is_point_solid(cell)

static func get_safe_cell(cell: Vector2i):
	const MAX_SEARCH_RADIUS: int = 4 # Maximum number of tiles to search outward

	if not is_cell_blocked(cell):
		return cell # The cell is already free

	var visited: Dictionary = {}
	visited[cell] = true

	var queue: Array[Vector2i] = [cell]
	var directions: Array[Vector2i] = [
		Vector2i(0, -1), # Up
		Vector2i(1, 0), # Right
		Vector2i(0, 1), # Down
		Vector2i(-1, 0) # Left
	]

	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		
		# Check distance from original cell
		if abs(cell.x - current.x) + abs(cell.y - current.y) > MAX_SEARCH_RADIUS:
			continue

		for dir: Vector2i in directions:
			var neighbor: Vector2i = current + dir
			if neighbor in visited:
				continue
			visited[neighbor] = true

			if not is_cell_blocked(neighbor):
				return neighbor # Found a valid, unblocked cell

			queue.append(neighbor) # Keep searching outward

	return null # Fallback, no free cell found within radius


static func get_grass_cells() -> Array[Vector2i]:
	var grass_cell_type = Vector2i(0, 3)

	var cells_32x32: Array[Vector2i] = _get_cells_with_atlas_coords(grass_cell_type)

	return cells_32x32

static func get_dirt_cells() -> Array[Vector2i]:
	var dirt_cell_type = Vector2i(2, 1)

	var cells_32x32: Array[Vector2i] = _get_cells_with_atlas_coords(dirt_cell_type)

	return cells_32x32

static func _get_cells_with_atlas_coords(target_coords: Vector2i) -> Array[Vector2i]:
	var cells_64x64: Array[Vector2i] = []

	var used_rect: Rect2i = GameManager.terrain.get_used_rect()
	for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			var cell = Vector2i(x, y)

			if GameManager.terrain.get_cell_source_id(cell) == -1:
				continue # empty cell

			var coords = GameManager.terrain.get_cell_atlas_coords(cell)
			if coords == target_coords:
				cells_64x64.append(cell)

	var cells_32x32: Array[Vector2i] = []
	for cell in cells_64x64:
		cells_32x32.append(Vector2i(cell.x * 2, cell.y * 2))
		cells_32x32.append(Vector2i(cell.x * 2 + 1, cell.y * 2))
		cells_32x32.append(Vector2i(cell.x * 2, cell.y * 2 + 1))
		cells_32x32.append(Vector2i(cell.x * 2 + 1, cell.y * 2 + 1))

	return cells_32x32
