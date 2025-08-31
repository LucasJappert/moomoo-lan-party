class_name MyCamera
extends Node

static var camera: Camera2D

static var _zoom_level := 1.6
static var _zoom_step := 0.05
static var _zoom_min := 0.7
static var _zoom_max := 10.0

const _bounds := Rect2(-100, -500, 1600, 1600)
const EDGE_MARGIN := 20
const CAMERA_SPEED := 800.0

static var _is_dragging := false
static var _last_mouse_position := Vector2.ZERO

static var _follow_player := true

# NEW: keep a processing instance so _process() runs
static var _processor: MyCamera

func _ready() -> void:
	# Ensure this node actually processes each frame
	set_process(true)

static func set_screen_size():
	var screen_size = DisplayServer.screen_get_size(0)
	var new_width = int(screen_size.x * 0.7)
	var new_height = int(new_width * 9.0 / 16.0)
	DisplayServer.window_set_size(Vector2i(new_width, new_height))
	var pos_x = screen_size.x - new_width
	var pos_y = 200
	DisplayServer.window_set_position(Vector2i(pos_x, pos_y))

static func create_camera(spawn_position: Vector2 = Moomoo.SPAWN_POSITION):
	# NEW: add a processing node once
	if _processor == null:
		_processor = MyCamera.new()
		_processor.name = "MyCameraProcessor"
		GameManager.add_child(_processor)

	MyCamera.camera = Camera2D.new()
	MyCamera.camera.position = MapManager.cell_to_world(spawn_position)
	MyCamera.camera.zoom = Vector2.ONE * _zoom_level
	GameManager.add_child(MyCamera.camera)
	MyCamera.camera.make_current()

static func update_camera_position(pos: Vector2):
	if camera == null:
		return
	camera.position = pos

static func update_camera_position_to_my_player():
	if camera == null: return
	var p := Player.get_my_player()
	if p == null: return
	update_camera_position(p.global_position)
	camera.global_position = camera.global_position.clamp(_bounds.position, _bounds.position + _bounds.size)

static func set_follow_player(on: bool) -> void:
	_follow_player = on
	if _follow_player:
		update_camera_position_to_my_player()
	else:
		_is_dragging = false

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
	if _follow_player: return
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

func _process(_delta: float) -> void:
	if MyCamera.camera == null: return
	if MyCamera._follow_player:
		MyCamera.update_camera_position_to_my_player()

static func is_following_player():
	return _follow_player