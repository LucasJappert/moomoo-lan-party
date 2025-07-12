class_name GuiEffect

extends Control

@onready var _sprite = $Sprite2D
var is_permanent: bool = false
var _duration: float = 0 # In seconds
var _elapsed: float = 0
var _effect: CombatEffect
var my_owner: Entity

static func get_instance(p_effect: CombatEffect) -> GuiEffect:
	var gui_effect = load("res://scenes/GUI/gui_effect_scene.tscn").instantiate()
	gui_effect._initialize(p_effect)
	return gui_effect

func _initialize(p_effect: CombatEffect) -> void:
	_effect = ObjectHelpers.deep_clone(p_effect) as CombatEffect
	is_permanent = _effect.is_permanent
	_duration = _effect._duration_in_seconds

func _ready():
	my_owner = GlobalsEntityHelpers.get_owner(self)
	if not GameManager.MY_PLAYER: return

	var region_size = _effect._region_rect.size
	_sprite.region_rect = _effect._region_rect
	_sprite.scale = Vector2(32.0 / region_size.x, 32.0 / region_size.y)

	%Area2D.connect("mouse_entered", func():
		if _effect == null:
			print("GuiEffect: Effect is null")
			return
		MyTooltip.show_tooltip(_effect.effect_name, _effect.get_description(), 16)
	)
	%Area2D.connect("mouse_exited", func(): MyTooltip.hide_tooltip())


func _process(delta: float):
	if GameManager.MY_PLAYER == null: return
	if is_permanent: return

	_elapsed += delta
