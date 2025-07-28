@tool
extends Control
class_name MyProgressBarScene

@onready var progress_bar: ProgressBar = $ProgressBar

@export var progress_value_percent: float = 0.0:
	set(value):
		progress_value_percent = clamp(value, 0.0, 100.0)
		if is_inside_tree():
			progress_bar.value = progress_value_percent

@export var progress_color: Color = Color.GRAY:
	set(value):
		progress_color = value
		if is_inside_tree():
			_update_progress_bar_style()

var _lifetime_in_ms: float = 0.0
var _start_time_in_ms: float = 0.0
var _my_name: String
var _my_id: int

func init(my_name: String, lifetime_in_seconds: float = 1.0, _color: Color = Color.GRAY):
	_lifetime_in_ms = lifetime_in_seconds * 1000.0
	progress_color = _color
	progress_value_percent = 100.0
	_start_time_in_ms = Time.get_ticks_msec()
	_my_id = UniqueIdGenerator.get_id()
	_my_name = my_name

func _ready():
	progress_bar.value = progress_value_percent
	_update_progress_bar_style()
	if _start_time_in_ms == 0.0:
		_start_time_in_ms = Time.get_ticks_msec()

func _update_progress_bar_style():
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = progress_color

	var radius := 2
	stylebox.corner_radius_top_left = radius
	stylebox.corner_radius_top_right = radius
	stylebox.corner_radius_bottom_left = radius
	stylebox.corner_radius_bottom_right = radius

	stylebox.anti_aliasing = false

	progress_bar.set("theme_override_styles/fill", stylebox)

func _process(_delta: float) -> void:
	if _lifetime_in_ms <= 0.0:
		return

	var current_time_in_ms = Time.get_ticks_msec()
	var elapsed_time_in_ms = current_time_in_ms - _start_time_in_ms

	if elapsed_time_in_ms > _lifetime_in_ms:
		queue_free()
		return

	var remaining_percent = 100.0 - (elapsed_time_in_ms * 100.0 / _lifetime_in_ms)
	progress_value_percent = remaining_percent
