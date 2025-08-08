@tool
extends HBoxContainer
class_name MyCheckScene

@onready var _check_texture: TextureRect = %CheckTexture
@onready var _label: Label = %Label


var on_pressed: Callable

@export var checked: bool = false:
	set(value):
		checked = value
		if is_inside_tree(): _update_check()

@export var label_text: String = "":
	set(value):
		label_text = value
		if is_inside_tree(): _update_label()

func _ready():
	_update_check()
	_update_label()
	connect("gui_input", _on_button_click)

func _on_button_click(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if on_pressed and on_pressed.is_valid():
			on_pressed.call()
			set_checked(true)

func _update_check(): _check_texture.visible = checked if checked else false

func _update_label(): if _label: _label.text = label_text

func set_checked(value: bool) -> void:
	checked = value