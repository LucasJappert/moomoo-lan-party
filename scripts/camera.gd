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

static func process(delta: float) -> void:
	if not camera or Main.MY_PLAYER_ID < 0: return

	var window_is_focused = DisplayServer.window_is_focused()
	var window_is_minimized = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED
	if not window_is_focused or window_is_minimized: return

	var window_is_maximized = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED

	if window_is_focused && not window_is_maximized:
		if Main.VIEWPORT_MOUSE_POSITION.x < 0 or Main.VIEWPORT_MOUSE_POSITION.x > Main.SCREEN_SIZE.x: return
		if Main.VIEWPORT_MOUSE_POSITION.y < 0 or Main.VIEWPORT_MOUSE_POSITION.y > Main.SCREEN_SIZE.y: return

	var direction := Vector2.ZERO

	if Main.VIEWPORT_MOUSE_POSITION.x <= EDGE_MARGIN:
		direction.x -= 1
	elif Main.VIEWPORT_MOUSE_POSITION.x >= Main.SCREEN_SIZE.x - EDGE_MARGIN:
		direction.x += 1

	if Main.VIEWPORT_MOUSE_POSITION.y <= EDGE_MARGIN:
		direction.y -= 1
	elif Main.VIEWPORT_MOUSE_POSITION.y >= Main.SCREEN_SIZE.y - EDGE_MARGIN:
		direction.y += 1

	if direction == Vector2.ZERO: return
	
	camera.global_position += direction.normalized() * CAMERA_SPEED * delta
	camera.global_position = camera.global_position.clamp(_bounds.position, _bounds.position + _bounds.size)
