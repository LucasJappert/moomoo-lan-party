class_name MyCamera

extends Node

static var camera: Camera2D # Store the camera
static var _zoom_level := 1.3 # Initial zoom
static var _zoom_step := 0.1 # Amount of zoom per scroll
static var _zoom_min := 0.5 # Minimum zoom
static var _zoom_max := 10.0 # Maximum zoom

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

	new_camera.position = Vector2.ZERO
	new_camera.zoom = Vector2.ONE * _zoom_level

	my_player.add_child(new_camera)

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

	camera.zoom = Vector2.ONE * _zoom_level
