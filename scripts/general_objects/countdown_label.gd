class_name CountdownLabel

extends Node2D

const SCENE = preload("res://scenes/general_objects/countdown_label.tscn")
@onready var label: Label = $Label

var text_to_show: String
var duration := 1
var speed := MapManager.TILE_SIZE_INT * 6
var fade_out := true
var SCALE_FROM = Vector2(1, 1)
var SCALE_TO = Vector2(0.5, 0.5)

func _ready():
	label.text = text_to_show
	await get_tree().process_frame
	label.modulate.a = 1.0
	label.scale = SCALE_FROM

	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position:y", global_position.y - speed, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): queue_free())

static func show_countdown_number(message: String):
	var countdown_label = SCENE.instantiate()
	countdown_label.text_to_show = message
	var screen_center := MyMain.SCREEN_SIZE / 2
	countdown_label.global_position = screen_center - Vector2(0, MapManager.TILE_SIZE_INT * 6)
	GameManager.my_main.gui_scene.add_child(countdown_label)
