class_name MyCamera

extends Node

static var camera: Camera2D # Store the camera
static var _zoom_level := 1.3 # Initial zoom
static var _zoom_step := 0.025 # Amount of zoom per scroll
static var _zoom_min := 0.7 # Minimum zoom
static var _zoom_max := 10.0 # Maximum zoom

const _bounds := Rect2(-100, -500, 1600, 1600) # x, y, width, height
const EDGE_MARGIN := 20
const CAMERA_SPEED := 800.0 # px/seg

static func set_screen_size():
	var screen_size = DisplayServer.screen_get_size(0)

	var new_width = int(screen_size.x * 0.4)
	var new_height = int(new_width * 9.0 / 16.0)

	DisplayServer.window_set_size(Vector2i(new_width, new_height))

	var pos_x = screen_size.x - new_width
	var pos_y = screen_size.y - new_height
	DisplayServer.window_set_position(Vector2i(pos_x, pos_y))

static func create_camera(my_player: Player):
	var new_camera = Camera2D.new()
	MyCamera.camera = new_camera

	new_camera.global_position = my_player.global_position
	new_camera.zoom = Vector2.ONE * _zoom_level

	GameManager.add_child(new_camera)
	# my_player.add_child(new_camera)

	new_camera.make_current()
	print("Camera added to player: " + str(my_player.name))

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
	if not camera: return

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
