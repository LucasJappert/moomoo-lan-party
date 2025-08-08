extends Control
class_name MenuScene

@onready var _main_container: Control = %MainContainer
@onready var _resume_button: MyButton = %ResumeButton
@onready var _restart_button: MyButton = %RestartButton
@onready var _exit_button: MyButton = %ExitButton
@onready var _menu_button: MyButton = %MenuButton
const HIDDEN_POSITION := Vector2(0, -250)
const VISIBLE_POSITION := Vector2(0, 216)
const CHAIN_VOLUME := -5

func _ready():
	LanguageManager.translate_ui(self)
	_menu_button.on_pressed = func(): MainScene.set_paused(true, true, true)
	_main_container.position = HIDDEN_POSITION
	EventBus.connect_to_paused(func(_paused: bool, _show_menu: bool):
		if _paused and _show_menu: _show_me()
		if not _paused: _hide_me()
	)
	_resume_button.on_pressed = func(): MainScene.set_paused(false)
	_restart_button.on_pressed = _restart_game
	_exit_button.on_pressed = func(): get_tree().quit()

func _show_me() -> void:
	SoundsHelper.play_sfx("res://sounds/generals/chains.wav", CHAIN_VOLUME, 2)
	_apply_tween_when_appear()

func _hide_me() -> void:
	MainScene.set_paused(false)
	SoundsHelper.play_sfx("res://sounds/generals/chains.wav", CHAIN_VOLUME, 2)
	_aplly_tween_when_disappear()

func _restart_game():
	MainScene.set_paused(false)
	HeroPickerScene.load_scene()

const _TWEEN_DURATION := 0.5
func _apply_tween_when_appear():
	var custom_tween := MyCustomTween.new(_main_container)
	custom_tween.tween_property(_main_container, "position", VISIBLE_POSITION, _TWEEN_DURATION, Tween.TRANS_SINE, Tween.EASE_OUT)
	custom_tween.start()

func _aplly_tween_when_disappear():
	var custom_tween := MyCustomTween.new(_main_container)
	custom_tween.tween_property(_main_container, "position", HIDDEN_POSITION, _TWEEN_DURATION * 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
	custom_tween.start()
