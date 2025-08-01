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
var my_name: String
var _my_id: int
var _start_time_in_ms: int
var _start_total_paused_time: int


func init(_my_name: String, lifetime_in_seconds: float = 1.0, _color: Color = Color.GRAY):
	_lifetime_in_ms = lifetime_in_seconds * 1000.0
	progress_color = _color
	progress_value_percent = 100.0
	_start_time_in_ms = Time.get_ticks_msec()
	_my_id = UniqueIdGenerator.get_id()
	my_name = _my_name
	start_lifetime(lifetime_in_seconds)

func _ready():
	progress_bar.value = progress_value_percent
	_update_progress_bar_style()
	if _start_time_in_ms == 0.0:
		_start_time_in_ms = Time.get_ticks_msec()

func start_lifetime(lifetime_in_seconds: float) -> void:
	_lifetime_in_ms = lifetime_in_seconds * 1000.0
	_start_time_in_ms = Time.get_ticks_msec()
	_start_total_paused_time = MainScene.total_paused_time # asumimos que es accesible como estática

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
	if MainScene.PAUSED: return
	if _lifetime_in_ms <= 0.0: return

	var current_time_in_ms = Time.get_ticks_msec()
	var paused_offset = MainScene.total_paused_time - _start_total_paused_time
	var elapsed_time_in_ms = current_time_in_ms - _start_time_in_ms - paused_offset

	if elapsed_time_in_ms > _lifetime_in_ms:
		return queue_free()

	var remaining_percent = 100.0 - (elapsed_time_in_ms * 100.0 / _lifetime_in_ms)
	progress_value_percent = remaining_percent

func update_lifetime(new_lifetime_in_seconds: float) -> void:
	var current_time_in_ms = Time.get_ticks_msec()
	var elapsed_ms = current_time_in_ms - _start_time_in_ms
	var remaining_ms = _lifetime_in_ms - elapsed_ms
	var new_lifetime_ms = new_lifetime_in_seconds * 1000.0

	if new_lifetime_ms > remaining_ms:
		# Reiniciar desde 100% con el nuevo tiempo
		_lifetime_in_ms = new_lifetime_ms
		_start_time_in_ms = current_time_in_ms
		progress_value_percent = 100.0
