class_name MyCamera

extends Node

static var camera: Camera2D # Store the camera
static var _zoom_level := 1.3 # Initial zoom
static var _zoom_step := 0.05 # Amount of zoom per scroll
static var _zoom_min := 0.7 # Minimum zoom
static var _zoom_max := 10.0 # Maximum zoom

const _bounds := Rect2(-100, -500, 1600, 1600) # x, y, width, height
const EDGE_MARGIN := 20
const CAMERA_SPEED := 800.0 # px/seg

static var _is_dragging := false
static var _last_mouse_position := Vector2.ZERO


static func set_screen_size():
	var screen_size = DisplayServer.screen_get_size(0)

	var new_width = int(screen_size.x * 0.7)
	var new_height = int(new_width * 9.0 / 16.0)

	DisplayServer.window_set_size(Vector2i(new_width, new_height))

	var pos_x = screen_size.x - new_width
	var pos_y = 200
	DisplayServer.window_set_position(Vector2i(pos_x, pos_y))

static func create_camera(spawn_position: Vector2 = Moomoo.SPAWN_POSITION):
	MyCamera.camera = Camera2D.new()

	MyCamera.camera.position = MapManager.cell_to_world(spawn_position)

	MyCamera.camera.zoom = Vector2.ONE * _zoom_level

	GameManager.add_child(MyCamera.camera)

	MyCamera.camera.make_current()

static func update_camera_position(pos: Vector2):
	camera.position = pos
	
static func update_camera_position_to_my_player():
	if GameManager.MY_PLAYER == null: return

	update_camera_position(GameManager.MY_PLAYER.global_position)

static func try_update_zoom(event: InputEvent):
	if camera == null:
		return
	if event is not InputEventMouseButton:
		return

	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom_level = max(_zoom_level - _zoom_step, _zoom_min)
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom_level = min(_zoom_level + _zoom_step, _zoom_max)

	snapped(_zoom_level, 0.001)

	camera.zoom = Vector2.ONE * _zoom_level

static func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_dragging = event.pressed
			if _is_dragging:
				_last_mouse_position = event.position
	elif event is InputEventMouseMotion and _is_dragging:
		var delta = event.position - _last_mouse_position
		_last_mouse_position = event.position
		camera.global_position -= delta / camera.zoom
		camera.global_position = camera.global_position.clamp(_bounds.position, _bounds.position + _bounds.size)
