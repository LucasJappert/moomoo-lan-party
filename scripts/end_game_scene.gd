extends Control
class_name EndGameScene

@onready var _main_container: Control = %MainContainer
@onready var _retry_button: MyButton = %RetryButton
@onready var _statistic_label: Label = %StatisticLabel
@onready var _defeat_label: Label = %DefeatLabel

const WIN_COLOR: Color = Color(0.5, 1.0, 0.5)
const LOSE_COLOR: Color = Color(1.0, 0.5, 0.5)

func _ready():
	LanguageManager.translate_ui(self)
	visible = false
	EventBus.connect_to_entity_died(_verify_end_game)

	_retry_button.on_pressed = GameManager.restart_game
	pass

func _verify_end_game(_entity_died: Entity, _killed_by: Entity) -> void:
	if not GameManager.GAME_RUNNING: return
	if not (_entity_died.is_my_player() or _entity_died is Moomoo): return

	# Moomoo is enemy of player and is dead
	if _entity_died is Moomoo:
		if Moomoo.is_awake(): return _show_me(true)
		return _show_me(false)

	if _entity_died.is_my_player(): return _show_me(false)


func _show_me(did_win: bool) -> void:
	_statistic_label.text = GameManager.MY_PLAYER.statistics.get_summary()

	var final_chat := InGameDialogsManager.final_message(did_win) \
	+"\n\n ####################### & #######################" \
	+"\n" + InGameDialogsManager.thanks() \
	+"\n ####################### & #######################"

	InGameDialogsManager.show(final_chat, 60 * 60) # Mantenemos por 1 hora
	_defeat_label.text = "YOUWIN" if did_win else "YOULOSE"
	visible = true
	apply_tween_when_appear()
	_defeat_label.modulate = LOSE_COLOR
	MainScene.set_paused(true, false)

func apply_tween_when_appear():
	# _main_container.scale = Vector2.ZERO
	_main_container.rotation = 0
	_main_container.modulate.a = 0

	var tween := _main_container.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	# Escalado
	# tween.tween_property(_main_container, "scale", Vector2.ONE, 0.8)

	# Rotación en paralelo
	# tween.parallel().tween_property(_main_container, "rotation", 3 * TAU, 0.8)
	tween.parallel().tween_property(_main_container, "modulate: a", 1, 0.4)
