class_name GuiEffect

extends Control

const EFFECT_SCENE := preload("res://scenes/GUI/gui_effect_scene.tscn")

@onready var _sprite = $Sprite2D
@onready var _label = %Label
var is_permanent: bool = false
var _duration: float = 0 # In seconds
var _elapsed_in_sec: float = 0
var _effect: CombatEffect
var my_owner: Entity

static func get_instance(p_effect: CombatEffect) -> GuiEffect:
	var gui_effect = EFFECT_SCENE.instantiate()
	gui_effect._initialize(p_effect)
	return gui_effect

func _initialize(p_effect: CombatEffect) -> void:
	_effect = ObjectHelpers.deep_clone(p_effect) as CombatEffect
	is_permanent = _effect.is_permanent
	_duration = _effect.duration_in_seconds

func _ready():
	my_owner = GlobalsEntityHelpers.get_owner(self)
	if not GameManager.MY_PLAYER: return

	var region_size = _effect._region_rect.size
	_sprite.region_rect = _effect._region_rect
	_sprite.scale = Vector2(48.0 / region_size.x, 48.0 / region_size.y)
	_label.text = ""

func _get_seconds_left() -> String:
	return StringHelpers.format_float(max(_duration - _elapsed_in_sec, 0), 1)

func _process(delta: float):
	_verify_tooltip()

	_try_set_label()

	if GameManager.MY_PLAYER == null: return
	if is_permanent: return

	_elapsed_in_sec += delta

func _try_set_label() -> void:
	if _effect.effect_name == SkillBloodFury.NAME:
		if _effect.get_level() > 1: _label.text = str(_effect.get_level())
		else: _label.text = ""
	
	if not _effect.is_permanent:
		if _elapsed_in_sec >= _duration:
			_label.text = ""
			return
		_label.text = _get_seconds_left()
		if _label.text == "0": _label.text = ""

func _verify_tooltip() -> void:
	if not _effect: return

	var is_hovering := get_global_rect().has_point(get_global_mouse_position())
	if not is_hovering: return

	MyTooltip.show_tooltip(_effect.effect_name, _effect.get_description(), 20, false)
