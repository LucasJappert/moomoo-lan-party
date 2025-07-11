extends CanvasLayer
class_name EndGameScene

@onready var _main_container: Control = %MainContainer
@onready var _retry_button: NinePatchRect = %RetryButton
@onready var _statistic_label: Label = %StatisticLabel
@onready var _defeat_label: Label = %DefeatLabel

const WIN_COLOR: Color = Color(0.5, 1.0, 0.5)
const LOSE_COLOR: Color = Color(1.0, 0.5, 0.5)

func _init():
	print("⚠️ EndGameScene instanciado. Stack trace:")
	print_stack()

func _ready():
	visible = false
	EventBus.connect_to_entity_died(func(_entity_died: Entity, _killed_by: Entity):
		if _entity_died.is_my_player():
			_statistic_label.text = _entity_died.statistics.get_summary()
			_show_me()
	)

	# TODO: Create a helper to simplify this connection
	_retry_button.connect("gui_input", func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_restart_game()
	)
	pass

func _show_me() -> void:
	GameManager.main_scene.pause()
	visible = true
	apply_tween_when_appear()
	_defeat_label.text = "YOU LOST"
	_defeat_label.modulate = LOSE_COLOR

func _restart_game() -> void:
	visible = false

	HeroPickerScene.load_scene()

func apply_tween_when_appear():
	_main_container.scale = Vector2.ZERO
	_main_container.rotation = 0
	_main_container.modulate.a = 0

	var tween := _main_container.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	# Escalado
	tween.tween_property(_main_container, "scale", Vector2.ONE, 0.8)

	# Rotación en paralelo
	tween.parallel().tween_property(_main_container, "rotation", 3 * TAU, 0.8)
	tween.parallel().tween_property(_main_container, "modulate:a", 1, 0.8)
