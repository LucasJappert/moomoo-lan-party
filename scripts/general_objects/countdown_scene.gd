class_name CountdownScene

extends Node2D

@onready var label_number_model: Label = %LabelNumberModel
@onready var start_now_button: NinePatchRect = %StartNowButton
@onready var numbers_container: CenterContainer = %NumbersContainer
@onready var numbers_container2: Node2D = %NumbersContainer2

var text_to_show: String
var duration := 1
var speed := MapManager.TILE_SIZE_INT * 5
var fade_out := true
var SCALE_FROM = Vector2(1, 1)
var SCALE_TO = Vector2(0.5, 0.5)
var final_message = false

func _ready():
	label_number_model.visible = false
	_clean_numbers_container()
	var screen_center := get_viewport().get_visible_rect().size / 2
	global_position = screen_center - Vector2(0, MapManager.TILE_SIZE_INT * 7)
	start_now_button.connect("gui_input", func(event: InputEvent): _on_start_now_button_click(event))

func _clean_numbers_container():
	for child in numbers_container2.get_children(): child.queue_free()

func add_new_label(message: String, _final_message: bool = false):
	if _final_message: _clean_numbers_container()

	start_now_button.visible = not _final_message
	SoundsHelper.play_beep()
	
	var new_label: Label = label_number_model.duplicate()
	new_label.visible = true
	new_label.text = message
	new_label.modulate.a = 1.0
	new_label.scale = SCALE_FROM
	new_label.position = Vector2.ZERO - Vector2(0, MapManager.TILE_SIZE_INT)
	var tween := new_label.create_tween()
	tween.tween_property(new_label, "position:y", new_label.position.y - speed, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(new_label, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(new_label.queue_free)

	numbers_container2.add_child(new_label)


func _on_start_now_button_click(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		EnemiesWavesController.skip_countdown()

static func show_countdown_number(message: String, _final_message: bool = false):
	GameManager.game_world.gui_scene.countdown_scene.add_new_label(message, _final_message)
