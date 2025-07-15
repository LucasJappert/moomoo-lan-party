extends Node
class_name CursorManager

# Enum for the available cursor types
enum CursorType {
	SWORD,
	DEFAULT,
	CAST
}

# Path to the cursor textures
const CURSORS := {
	CursorType.SWORD: {
		"texture": preload("res://assets/cursors/sword.png"),
		"hotspot": Vector2(32, 32),
	},
	CursorType.DEFAULT: {
		"texture": preload("res://assets/cursors/default.png"),
		"hotspot": Vector2(32, 32),
	},
	CursorType.CAST: {
		"texture": preload("res://assets/cursors/cast.png"),
		"hotspot": Vector2(32, 32),
	}
}

const MOUSE_MOVE_RECT := Rect2(256, 288, 32, 32)
# Static tracking
static var _current_cursor = -1
static var _initialized := false

static func _initialize():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_cursor(CursorType.DEFAULT) # Set the default cursor
	_initialized = true

static func _static_process(_delta):
	if not _initialized: _initialize()
	
	# Change cursor dynamically depending on the hovered entity
	if not GameManager.MY_PLAYER: return set_cursor(CursorType.DEFAULT)

	if GameManager.MY_PLAYER.charged_skill: return set_cursor(CursorType.CAST)

	if ObjectHelpers.is_enemy(AreaHovered.hovered_entity): return set_cursor(CursorType.SWORD)

	set_cursor(CursorType.DEFAULT)

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

static func show_move_effect():
	var effect := Sprite2D.new()
	effect.texture = SpritesHelper.get_texture_from_region(MOUSE_MOVE_RECT)
	effect.global_position = MapManager.HOVERED_CELL_IN_GLOBAL_POSITION
	GameManager.game_world.over_terrain_layer.add_child(effect)

	const DURATION := 1
	var tween := effect.create_tween()
	# tween.tween_property(effect, "scale", Vector2.ZERO, DURATION).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(effect, "modulate", Color(1, 1, 1, 0), DURATION)
	# tween.parallel().tween_property(effect, "rotation", PI * 4, DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(effect.queue_free)