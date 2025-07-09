extends CanvasLayer
class_name EndGameScene

@onready var _retry_button: NinePatchRect = %RetryButton
@onready var _statistic_label: Label = %StatisticLabel

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

func _restart_game() -> void:
	visible = false

	HeroPickerScene.load_scene()
