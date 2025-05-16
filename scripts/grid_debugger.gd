extends Node2D

@export var grid_color: Color = Color(0, 0, 0, 0.1)
@export var text_color: Color = Color(1, 1, 1)
@export var font: Font
@export var solid_cell_color: Color = Color(1, 0, 0, 0.5)
var hovered_cell: Vector2i
const _PRINT_COORDINATES := false
const _DRAW_PATHS := false
const _DRAW_SOLID_CELLS := false

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _process(_delta):
	if MultiplayerManager.MY_PLAYER != null:
		hovered_cell = AStarGridManager.world_to_cell(MultiplayerManager.MY_PLAYER.get_global_mouse_position())
		
	queue_redraw()


func _draw():
	var tile_size := MapConstants.TILE_SIZE

	# Obtener el viewport en coordenadas globales
	var canvas_transform := get_canvas_transform().affine_inverse()
	var viewport_rect := get_viewport().get_visible_rect()

	var top_left := canvas_transform * viewport_rect.position
	var bottom_right := canvas_transform * (viewport_rect.position + viewport_rect.size)

	# Convertimos las coordenadas mundiales a celdas
	var start_cell := AStarGridManager.world_to_cell(top_left)
	var end_cell := AStarGridManager.world_to_cell(bottom_right)

	# Clamp para no salir del region definido
	start_cell = clamp_to_region(start_cell)
	end_cell = clamp_to_region(end_cell)

	for y in range(start_cell.y, end_cell.y + 1):
		for x in range(start_cell.x, end_cell.x + 1):
			var cell := Vector2i(x, y)
			var pos := AStarGridManager.cell_to_world(cell)

			draw_rect(Rect2(pos - tile_size / 2.0, tile_size), grid_color, false)
			
			_try_draw_solid_cells(cell, pos)

			_try_print_coordinates(pos, x, y)

	_try_draw_paths()

	_draw_hovered_cell()


func clamp_to_region(cell: Vector2i) -> Vector2i:
	var region := AStarGridManager.astar_grid.region
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

	for entity in GameManager.get_entities():
		for cell in entity.current_path:
			if AStarGridManager.astar_grid.is_in_boundsv(cell):
				var pos := AStarGridManager.cell_to_world(cell)
				draw_rect(Rect2(pos - AStarGridManager.tile_size / 2.0, AStarGridManager.tile_size), Color(1, 1, 0, 0.5), true)
				draw_string(font, pos, "X")

func _try_draw_solid_cells(cell: Vector2i, pos: Vector2):
	if not _DRAW_SOLID_CELLS:
		return

	if not AStarGridManager.astar_grid.is_in_boundsv(cell):
		return
	# Draw solid cells
	if AStarGridManager.astar_grid.is_point_solid(cell):
		draw_rect(Rect2(pos - AStarGridManager.tile_size / 2.0, AStarGridManager.tile_size), solid_cell_color, true)

func _draw_hovered_cell():
	if MultiplayerManager.MY_PLAYER == null:
		return

	var pos := AStarGridManager.cell_to_world(hovered_cell)
	draw_rect(Rect2(pos - MapConstants.TILE_SIZE / 2.0, MapConstants.TILE_SIZE), Color(0, 0, 0, 0.2), true)