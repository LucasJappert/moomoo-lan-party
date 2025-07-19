extends CanvasLayer
class_name EndGameScene

@onready var _main_container: Control = %MainContainer
@onready var _retry_button: MyButton = %RetryButton
@onready var _statistic_label: Label = %StatisticLabel
@onready var _defeat_label: Label = %DefeatLabel

const WIN_COLOR: Color = Color(0.5, 1.0, 0.5)
const LOSE_COLOR: Color = Color(1.0, 0.5, 0.5)

func _ready():
	visible = false
	EventBus.connect_to_entity_died(func(_entity_died: Entity, _killed_by: Entity):
		if _entity_died.is_my_player():
			_statistic_label.text = _entity_died.statistics.get_summary()
			_show_me()
	)

	_retry_button.on_pressed = _restart_game
	pass

func _show_me() -> void:
	visible = true
	apply_tween_when_appear()
	_defeat_label.text = "YOU LOST"
	_defeat_label.modulate = LOSE_COLOR
	MainScene.set_paused(true, false)

func _restart_game() -> void:
	visible = false

	MainScene.set_paused(false)
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
