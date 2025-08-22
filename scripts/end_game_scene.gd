extends Control
class_name EndGameScene

@onready var _main_container: Control = %MainContainer
@onready var _retry_button: MyButton = %RetryButton
@onready var _statistic_label: Label = %StatisticLabel
# @onready var _defeat_label: Label = %DefeatLabel

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

	EventBus.emit_game_ended()
	# Moomoo is enemy of player and is dead
	if _entity_died is Moomoo:
		if Moomoo.is_awake(): return _show_me(true)
		return _show_me(false)

	if _entity_died.is_my_player(): return _show_me(false)

func _show_me(did_win: bool) -> void:
	GameManager.PLAYER_WIN = did_win
	if did_win: _effects_on_win()
	
	SoundsHelper.play_sfx("res://sounds/moomoo/laugh1.wav", 0, 1)
	SoundsHelper.play_sfx("res://sounds/moomoo/steps.wav", 0, 1, func(): SoundsHelper.play_sfx("res://sounds/moomoo/laugh1.wav", 0, 1))

	_statistic_label.text = GameManager.MY_PLAYER.statistics.get_summary()

	var final_chat: String = ""
	final_chat += "\n[font_size=20]%s[/font_size]" % Player.get_last_damages_message()
	
	var hex := "#038e36ff" if did_win else "#b52c2cff"
	final_chat += "\n[color=%s]%s[/color]" % [hex, InGameDialogsManager.final_message(did_win)]
	
	final_chat += "\n---------------------------------------------------"
	final_chat += "\n[font_size=20]%s[/font_size]" % InGameDialogsManager.thanks()
	final_chat += "\n---------------------------------------------------"

	InGameDialogsManager.show(final_chat, 60 * 60) # Mantenemos por 1 hora
	# _defeat_label.text = LanguageManager.translate("You Win" if did_win else "You Lose")
	# visible = true
	# apply_tween_when_appear()
	# _defeat_label.modulate = WIN_COLOR if did_win else LOSE_COLOR

func apply_tween_when_appear():
	_main_container.rotation = 0.0
	_main_container.modulate.a = 0.0

	var tween := _main_container.create_tween()
	# Lo ideal: setear transición/ease sobre el tweener que retorna tween_property
	var tw := tween.tween_property(_main_container, "modulate:a", 1.0, 0.4)
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _effects_on_win() -> void:
	# En tu EndGame / GameManager cuando detectás victoria:
	var pos := MapManager.cell_to_world(MapManager.world_to_cell(GameManager.MY_PLAYER.global_position))
	SmokeHelper.attach_victory_aura(GameManager.game_world.over_terrain_layer_layer_2, pos, 1.5, 1.2)

	# Si querés salpicar varios “pools” alrededor:
	for i in 4:
		var offset := Vector2(randf_range(-64, 64), randf_range(-48, 48))
		SmokeHelper.attach_victory_aura(GameManager.game_world.over_terrain_layer_layer_2, pos + offset, 1.2, randf_range(0.8, 1.4))