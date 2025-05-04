class_name MyCamera

extends Node

static var camera: Camera2D # Store the camera
static var _zoom_level := 1.0 # Initial zoom
static var _zoom_step := 0.1 # Amount of zoom per scroll
static var _zoom_min := 0.5 # Minimum zoom
static var _zoom_max := 3.0 # Maximum zoom

static func create_camera(my_player: Player):
	print("Creating camera")
	var new_camera = Camera2D.new()
	MyCamera.camera = new_camera

	new_camera.position = Vector2.ZERO
	new_camera.zoom = Vector2.ONE * 1

	my_player.add_child(new_camera)

	new_camera.make_current()

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
