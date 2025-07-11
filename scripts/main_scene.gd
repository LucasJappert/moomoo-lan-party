extends Node2D
class_name MainScene

@onready var my_tooltip: MyTooltip = $Layer10/MyTooltip
@onready var layer_1 = $Layer1
@onready var audio_node: Node = $Audio

var PAUSED = false

# Main.gd
func _ready():
	GameManager.main_scene = self
	SoundsHelper.initialize(audio_node)
	MyCamera.set_screen_size()
	MyCamera.create_camera()
	HeroPickerScene.load_scene()
	pass

func load_scene(scene):
	clear_scenes()
	layer_1.add_child(scene)

func clear_scenes():
	for child in layer_1.get_children():
		child.queue_free()

func toogle_pause():
	if PAUSED: resume()
	else: pause()

func pause():
	PAUSED = true

func resume():
	PAUSED = false