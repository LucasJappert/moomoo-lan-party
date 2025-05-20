class_name MapManager

const TILE_SIZE: Vector2 = Vector2(32, 32)

const grid_width: int = 56
const grid_height: int = 44
const grid_origin: Vector2i = Vector2i(-8, -12)

static var _astar_grid: AStarGrid2D = AStarGrid2D.new()


static func initialize():
	_astar_grid.region = Rect2i(grid_origin, Vector2i(grid_width, grid_height))
	_astar_grid.cell_size = TILE_SIZE
	_astar_grid.offset = Vector2(grid_origin.x * TILE_SIZE.x, grid_origin.y * TILE_SIZE.y) # ← 🔥 clave
	_astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS

	_astar_grid.update()

	for y in range(grid_origin.y, grid_origin.y + grid_height):
		for x in range(grid_origin.x, grid_origin.x + grid_width):
			var cell = Vector2i(x, y)
			_astar_grid.set_point_solid(cell, false)

	print("AStarGridManager ready")


static func find_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	if not _astar_grid.is_in_boundsv(start) or not _astar_grid.is_in_boundsv(end):
		return []
	var path: Array[Vector2i] = _astar_grid.get_id_path(start, end, true)
	if path.is_empty():
		return []
		
	path.remove_at(0) # Remove start from path
	return path


static func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / TILE_SIZE.x), floor(pos.y / TILE_SIZE.y))

static func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE_SIZE.x + TILE_SIZE.x / 2, cell.y * TILE_SIZE.y + TILE_SIZE.y / 2)
	
static func set_cell_blocked(cell: Vector2i, blocked: bool):
	if _astar_grid.is_in_boundsv(cell):
		_astar_grid.set_point_solid(cell, blocked)
		
static func set_cell_blocked_from_world(pos: Vector2, blocked: bool):
	set_cell_blocked(world_to_cell(pos), blocked)