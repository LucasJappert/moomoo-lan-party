class_name MyTooltip

extends Control

@onready var _panel: NinePatchRect = $Panel
@onready var _title: Label = $Panel/Title
@onready var _description: Label = $Panel/Description

const MARGINS = 20
const PANEL_WIDTH = 500


func _ready() -> void:
	visible = false
	_title.position = Vector2(MARGINS, MARGINS)
	_description.position = Vector2(MARGINS, _title.position.y + _title.get_combined_minimum_size().y + 5)


func _process(_delta):
	# if visible:
	# 	global_position = get_global_mouse_position() + Vector2(16, 16)
	return

func show_me(title: String, description: String, panel_width: int = PANEL_WIDTH) -> void:
	if panel_width == 0: panel_width = PANEL_WIDTH

	_title.set_size(Vector2(panel_width - MARGINS * 2, 0))
	_description.set_size(Vector2(panel_width - MARGINS * 2, 0))

	_title.text = title
	_description.text = description

	var title_height = _title.get_combined_minimum_size().y
	var description_height = _description.get_combined_minimum_size().y
	_panel.set_size(Vector2(panel_width, title_height + description_height + MARGINS * 2))

	visible = true
	_update_position()

func hide_me() -> void:
	visible = false

func _update_position() -> void:
	var mouse_pos = get_global_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	var tooltip_size = _panel.size

	var offset := Vector2(MARGINS, MARGINS)

	# Determine horizontal quadrant
	if mouse_pos.x > screen_size.x / 2.0:
		# Right side → move tooltip to the left
		offset.x = - tooltip_size.x - MARGINS
	else:
		# Left side → move tooltip to the right (default)
		offset.x = MARGINS

	# Determine vertical quadrant
	if mouse_pos.y > screen_size.y / 2.0:
		# Bottom → move up
		offset.y = - tooltip_size.y - MARGINS
	else:
		# Top → move down (default)
		offset.y = MARGINS

	var final_pos = mouse_pos + offset

	# Clamp to avoid going out of screen
	final_pos.x = clamp(final_pos.x, 0, screen_size.x - tooltip_size.x)
	final_pos.y = clamp(final_pos.y, 0, screen_size.y - tooltip_size.y)

	global_position = final_pos
