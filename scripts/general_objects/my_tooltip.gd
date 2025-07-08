class_name MyTooltip

extends Control

@onready var _panel: NinePatchRect = $Panel
@onready var _title: RichTextLabel = $Panel/Title
@onready var _description: RichTextLabel = $Panel/Description

const MARGINS = 20
const PANEL_WIDTH_IN_TILES: float = 14


func _ready() -> void:
	visible = false
	_title.position = Vector2(MARGINS, MARGINS)
	_description.position = Vector2(MARGINS, _title.position.y + _title.get_content_height() + 5)
	_title.bbcode_enabled = true
	_description.bbcode_enabled = true
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD


func _process(_delta):
	# if visible:
	# 	global_position = get_global_mouse_position() + Vector2(16, 16)
	return

func _show_me(title: String, description: String, width_in_tiles: float = PANEL_WIDTH_IN_TILES) -> void:
	var width_in_pixels = width_in_tiles * MapManager.TILE_SIZE_INT
	var content_width = width_in_pixels - MARGINS * 2

	_title.clear()
	_description.clear()
	_title.append_text("[u][b]" + title.to_upper() + "[/b][/u]")
	_description.append_text(description)

	# Step 1: Set width BEFORE calculating heights
	_title.set_size(Vector2(content_width, 0))
	_description.set_size(Vector2(content_width, 0))

	await get_tree().process_frame

	# Step 2: Now we can get the heights
	var title_height = _title.get_content_height()
	var description_height = _description.get_content_height()

	# Adjust heights
	_title.set_size(Vector2(content_width, title_height))
	_description.set_size(Vector2(content_width, description_height))
	_description.position = Vector2(MARGINS, _title.position.y + title_height + 5)

	# Final panel size
	_panel.set_size(Vector2(width_in_pixels, title_height + description_height + MARGINS * 2))
	set_size(_panel.size)

	visible = true
	_update_position()

func _hide_me() -> void:
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

static func show_tooltip(title: String, text: String, width_in_tiles: float = PANEL_WIDTH_IN_TILES) -> void:
	GameManager.my_main.my_tooltip._show_me(title, text, width_in_tiles)
static func hide_tooltip() -> void:
	GameManager.my_main.my_tooltip._hide_me()