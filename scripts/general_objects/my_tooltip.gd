class_name MyTooltip

extends Control

@onready var _panel: NinePatchRect = $Panel
@onready var _rich_title: RichTextLabel = $Panel/Title
@onready var _rich_description: RichTextLabel = $Panel/Description
var _current_description: String

var _show_until_frame: int = -1
var _force_visible: bool = false

const MARGINS = 20
const PANEL_WIDTH_IN_TILES: float = 14


func _ready() -> void:
	_panel.visible = false
	_rich_title.position = Vector2(MARGINS, MARGINS)
	_rich_description.position = Vector2(MARGINS, _rich_title.position.y + _rich_title.get_content_height() + 5)
	_rich_title.bbcode_enabled = true
	_rich_description.bbcode_enabled = true
	_rich_title.autowrap_mode = TextServer.AUTOWRAP_WORD
	_rich_description.autowrap_mode = TextServer.AUTOWRAP_WORD


func _process(_delta) -> void:
	if _force_visible:
		_panel.visible = true
		return
		
	if Engine.get_process_frames() > _show_until_frame: return _hide_me()

func _show_me(title: String, description: String, width_in_tiles: float = PANEL_WIDTH_IN_TILES, force_visible: bool = false) -> void:
	_force_visible = force_visible
	_show_until_frame = Engine.get_process_frames() + 5

	if description == _current_description: return

	_current_description = description

	var width_in_pixels = width_in_tiles * MapManager.TILE_SIZE_INT
	var content_width = width_in_pixels - MARGINS * 2

	_rich_title.clear()
	_rich_description.clear()
	_rich_title.append_text("[u][b]" + title.to_upper() + "[/b][/u]")
	_rich_description.append_text(description)

	# Step 1: Set width BEFORE calculating heights
	_rich_title.set_size(Vector2(content_width, 0))
	_rich_description.set_size(Vector2(content_width, 0))

	await get_tree().process_frame

	# Step 2: Now we can get the heights
	var title_height = _rich_title.get_content_height()
	var description_height = _rich_description.get_content_height()

	# Adjust heights
	_rich_title.set_size(Vector2(content_width, title_height))
	_rich_description.set_size(Vector2(content_width, description_height))
	_rich_description.position = Vector2(MARGINS, _rich_title.position.y + title_height + 5)

	# Final panel size
	_panel.set_size(Vector2(width_in_pixels, title_height + description_height + MARGINS * 2))
	set_size(_panel.size)

	_update_position()
	_panel.visible = true

func _hide_me() -> void:
	_force_visible = false
	_panel.visible = false
	_current_description = ""

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

	_panel.global_position = final_pos

static func show_tooltip(title: String, text: String, width_in_tiles: float = PANEL_WIDTH_IN_TILES, force_visible: bool = true) -> void:
	GameManager.main_scene.my_tooltip._show_me(title, text, width_in_tiles, force_visible)
static func hide_tooltip() -> void:
	GameManager.main_scene.my_tooltip._hide_me()
