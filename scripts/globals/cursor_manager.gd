extends Node
class_name CursorManager

# Enum for the available cursor types
enum CursorType {
	SWORD,
	HAND
}

# Path to the cursor textures
const CURSORS := {
	CursorType.SWORD: {
		"texture": preload("res://assets/cursors/sword.png"),
		"hotspot": Vector2(32, 32),
	},
	CursorType.HAND: {
		"texture": preload("res://assets/cursors/hand.png"),
		"hotspot": Vector2(32, 32),
	}
}

# Static tracking
static var _current_cursor = -1
static var _initialized := false

static func _initialize():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_cursor(CursorType.HAND) # Set the default cursor
	_initialized = true

static func _static_process(_delta):
	if not _initialized: _initialize()
	
	# Change cursor dynamically depending on the hovered entity
	if AreaHovered.hovered_entity is Enemy:
		set_cursor(CursorType.SWORD)
	else:
		set_cursor(CursorType.HAND)

static func set_cursor(cursor_type: CursorType):
	if cursor_type == _current_cursor: return # Already set

	var data = CURSORS.get(cursor_type)
	if data:
		Input.set_custom_mouse_cursor(
			data.texture,
			Input.CURSOR_ARROW,
			data.hotspot
		)
	else:
		push_warning("Cursor not defined for type: %s" % str(cursor_type))

	_current_cursor = cursor_type

static func reset_cursor():
	Input.set_custom_mouse_cursor(null)
	_current_cursor = -1
