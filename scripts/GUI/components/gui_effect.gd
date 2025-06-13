class_name GuiEffect

extends Control

const SCENE = preload("res://scenes/GUI/gui_effect_scene.tscn")

@onready var _sprite = $Sprite2D
var is_permanent: bool = false
var _duration: float = 0 # In seconds
var _elapsed: float = 0
var _effect: CombatEffect
var unique
var my_owner: Entity

static func get_instance(p_effect: CombatEffect) -> GuiEffect:
	var gui_effect = SCENE.instantiate()
	gui_effect._initialize(p_effect)
	return gui_effect

func _initialize(p_effect: CombatEffect) -> void:
	_effect = ObjectHelpers.deep_clone(p_effect) as CombatEffect
	is_permanent = _effect.is_permanent
	_duration = _effect._duration

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
		GameManager.show_tooltip(_effect.effect_name, _effect.get_description(), 500)
	)
	%Area2D.connect("mouse_exited", func(): GameManager.hide_tooltip())

func _process(delta: float):
	if GameManager.MY_PLAYER == null: return
	if is_permanent: return

	_elapsed += delta
	if _elapsed >= _duration: queue_free()

	_verify_existence_on_effects()

func _verify_existence_on_effects() -> void:
	if get_parent().name == GuiEffects.MY_EFFECTS_INSTANCE:
		if GameManager.MY_PLAYER.combat_data.get_effect_by_unique_name(_effect.unique_name_node) == null:
			return queue_free()
	
	if get_parent().name == GuiEffects.TARGET_EFFECTS_INSTANCE:
		var target = GameManager.MY_PLAYER.combat_data.get_target_entity()
		if target == null: return
		if target.combat_data.get_effect_by_unique_name(_effect.unique_name_node) == null:
			return queue_free()
