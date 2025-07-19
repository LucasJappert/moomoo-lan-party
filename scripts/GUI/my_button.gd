@tool
extends NinePatchRect
class_name MyButton

@export var text: String = "Default":
	set(value):
		text = value
		if is_inside_tree(): _update_label()
@export var force_width: int = 0:
	set(value):
		force_width = value
		if is_inside_tree(): _update_label()
@export var color: Color = Color(1, 1, 1):
	set(value):
		color = value
		if is_inside_tree(): _update_color()

@onready var _label: Label = %TextLabel
@onready var _border: NinePatchRect = %Border

var on_pressed: Callable


const MARGINS = 30

func _ready():
	_update_label()
	_update_color()
	connect("gui_input", _on_button_click)

func _on_button_click(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if on_pressed and on_pressed.is_valid():
			on_pressed.call()

func _update_border_size():
	if _border: _border.size = size

func _notification(what):
	if what == NOTIFICATION_RESIZED: _update_border_size()

func _update_label():
	_label.text = text
	
	var text_height = _label.get_minimum_size().y + MARGINS
	if force_width > 0:
		set_size(Vector2(force_width + MARGINS * 2, text_height))
		return

	var text_width = _label.get_minimum_size().x
	set_size(Vector2(text_width + MARGINS * 2, text_height))

func _update_color():
	if not _border: return
	_border.modulate = color
