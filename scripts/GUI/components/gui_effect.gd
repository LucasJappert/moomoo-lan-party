class_name GuiEffect

extends Control

@onready var _sprite = $Sprite2D
var is_permanent: bool = false
var _duration: float = 0 # In seconds
var _elapsed: float = 0
var _effect: CombatEffect
var my_owner: Entity
var _is_hovering := false

static func get_instance(p_effect: CombatEffect) -> GuiEffect:
	var gui_effect = load("res://scenes/GUI/gui_effect_scene.tscn").instantiate()
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
	_sprite.scale = Vector2(32.0 / region_size.x, 32.0 / region_size.y)

	connect("child_exiting_tree", _on_child_exiting_tree)
	%Area2D.connect("mouse_entered", _on_mouse_entered)
	%Area2D.connect("mouse_exited", _on_mouse_exited)

func _on_mouse_entered() -> void:
	if _effect == null: return print("GuiEffect: Effect is null")
	_is_hovering = true
	MyTooltip.show_tooltip(_effect.effect_name, _effect.get_description(), 16)
func _on_mouse_exited() -> void:
	_is_hovering = false
	MyTooltip.hide_tooltip()
func _on_child_exiting_tree(_child) -> void:
	if _is_hovering: MyTooltip.hide_tooltip()

func _process(delta: float):
	if GameManager.MY_PLAYER == null: return
	if is_permanent: return

	_elapsed += delta
