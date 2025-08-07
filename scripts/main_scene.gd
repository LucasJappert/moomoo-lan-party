extends Node2D
class_name MainScene

@onready var my_tooltip: MyTooltip = $Layer10/MyTooltip
@onready var layer_1 = $Layer1
@onready var audio_node: Node = $Audio

static var PAUSED = false
static var pause_start_time := 0
static var total_paused_time := 0

func _ready():
	GameManager.main_scene = self
	SoundsHelper.initialize(audio_node)
	MyCamera.set_screen_size()
	MyCamera.create_camera()
	# HeroPickerScene.load_scene()
	InitialScene.load_scene()
	pass

func load_scene(scene):
	clear_scenes()
	layer_1.add_child(scene)

# region 	GETTERs
static func get_elapsed_time_in_sec() -> float:
	return (Time.get_ticks_msec() - total_paused_time) / 1000.0
# endregion GETTERs

# region 	SETTERs
static func set_paused(_paused: bool, stop_time_scale := true, show_menu: bool = false) -> void:
	if PAUSED == _paused: return
	PAUSED = _paused
	if PAUSED:
		pause_start_time = Time.get_ticks_msec()
		if stop_time_scale: Engine.time_scale = 0
	else:
		total_paused_time += Time.get_ticks_msec() - pause_start_time
		Engine.time_scale = 1
	EventBus.emit_paused(_paused, show_menu)
# endregion SETTERs

func clear_scenes():
	for child in layer_1.get_children():
		child.queue_free()
