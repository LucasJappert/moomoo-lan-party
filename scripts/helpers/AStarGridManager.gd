extends Node

@export var tile_size: Vector2 = Vector2(32, 32)
const grid_width: int = 56
const grid_height: int = 44
const grid_origin: Vector2i = Vector2i(-8, -12)

var astar_grid: AStarGrid2D = AStarGrid2D.new()

func _ready():
	astar_grid.region = Rect2i(grid_origin, Vector2i(grid_width, grid_height))
	astar_grid.cell_size = tile_size
	astar_grid.offset = Vector2(grid_origin.x * tile_size.x, grid_origin.y * tile_size.y) # ← 🔥 clave
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS

	astar_grid.update()

	for y in range(grid_origin.y, grid_origin.y + grid_height):
		for x in range(grid_origin.x, grid_origin.x + grid_width):
			var cell = Vector2i(x, y)
			astar_grid.set_point_solid(cell, false)

	print("AStarGridManager ready")

func set_cell_blocked(cell: Vector2i, blocked: bool):
	if astar_grid.is_in_boundsv(cell):
		astar_grid.set_point_solid(cell, blocked)

func set_cell_blocked_from_world(pos: Vector2, blocked: bool):
	set_cell_blocked(world_to_cell(pos), blocked)

func find_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	if not astar_grid.is_in_boundsv(start) or not astar_grid.is_in_boundsv(end):
		return []
	var path: Array[Vector2i] = astar_grid.get_id_path(start, end, true)
	if path.is_empty():
		return []
		
	path.remove_at(0) # Remove start from path
	return path

func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / tile_size.x), floor(pos.y / tile_size.y))

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * tile_size.x + tile_size.x / 2, cell.y * tile_size.y + tile_size.y / 2)
