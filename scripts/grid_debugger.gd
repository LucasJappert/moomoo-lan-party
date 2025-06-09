extends Node2D

@export var grid_color: Color = Color(0, 0, 0, 0.1)
@export var text_color: Color = Color(1, 1, 1)
@export var font: Font
@export var solid_cell_color: Color = Color(1, 0, 0, 0.5)
var hovered_cell: Vector2i
const _DRAW_GRID := false
const _PRINT_COORDINATES := false
const _DRAW_PATHS := false
const _DRAW_SOLID_CELLS := false
const _DRAW_MOUSE_HOVERED_CELL := true

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _process(_delta):
	if GameManager.MY_PLAYER != null:
		hovered_cell = MapManager.world_to_cell(MyMain.GLOBAL_MOUSE_POSITION)
		
	queue_redraw()


func _draw():
	_draw_hovered_cell()

	if not _DRAW_GRID:
		return
		
	var tile_size := MapManager.TILE_SIZE

	# Obtener el viewport en coordenadas globales
	var canvas_transform := get_canvas_transform().affine_inverse()
	var viewport_rect := get_viewport().get_visible_rect()

	var top_left := canvas_transform * viewport_rect.position
	var bottom_right := canvas_transform * (viewport_rect.position + viewport_rect.size)

	# Convertimos las coordenadas mundiales a celdas
	var start_cell := MapManager.world_to_cell(top_left)
	var end_cell := MapManager.world_to_cell(bottom_right)

	# Clamp para no salir del region definido
	start_cell = clamp_to_region(start_cell)
	end_cell = clamp_to_region(end_cell)

	for y in range(start_cell.y, end_cell.y + 1):
		for x in range(start_cell.x, end_cell.x + 1):
			var cell := Vector2i(x, y)
			var pos := MapManager.cell_to_world(cell)

			draw_rect(Rect2(pos - tile_size / 2.0, tile_size), grid_color, false, 3.0, false)
			
			_try_draw_solid_cells(cell, pos)

			_try_print_coordinates(pos, x, y)

	_try_draw_paths()


func clamp_to_region(cell: Vector2i) -> Vector2i:
	var region := MapManager._astar_grid.region
	var max1 := region.position + region.size - Vector2i(1, 1)
	return cell.clamp(region.position, max1)

func _try_print_coordinates(pos: Vector2, x: int, y: int):
	if not _PRINT_COORDINATES:
		return

	if font and x % 2 == 0 and y % 2 == 0:
		var label := "%d,%d" % [x, y]
		var text_size := font.get_string_size(label)
		draw_string(font, pos - text_size / 2.0, label)

func _try_draw_paths():
	if not _DRAW_PATHS:
		return

	for entity in GameManager.entities.values():
		for cell in entity.movement_helper.current_path:
			if MapManager._astar_grid.is_in_boundsv(cell):
				var pos := MapManager.cell_to_world(cell)
				draw_rect(Rect2(pos - MapManager.TILE_SIZE / 2.0, MapManager.TILE_SIZE), Color(1, 1, 0, 0.5), true)
				draw_string(font, pos, "X")

func _try_draw_solid_cells(cell: Vector2, pos: Vector2):
	if not _DRAW_SOLID_CELLS:
		return

	if not MapManager._astar_grid.is_in_boundsv(cell):
		return
	# Draw solid cells
	if MapManager._astar_grid.is_point_solid(cell):
		draw_rect(Rect2(pos - MapManager.TILE_SIZE / 2.0, MapManager.TILE_SIZE), solid_cell_color, true)

func _draw_hovered_cell():
	if GameManager.MY_PLAYER == null: return

	var pos := MapManager.cell_to_world(hovered_cell)
	draw_rect(Rect2(pos - MapManager.TILE_SIZE / 2.0, MapManager.TILE_SIZE), Color(0, 0, 0, 0.2), true)