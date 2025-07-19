extends CanvasLayer
class_name MenuScene

@onready var _main_container: Control = %MainContainer

func _ready():
	visible = false
	EventBus.connect_to_paused(func(_paused: bool):
		print("Paused: ", _paused)
		if _paused: _show_me()
		else: _hide_me()
	)

func _show_me() -> void:
	visible = true
	apply_tween_when_appear()

func _hide_me() -> void:
	visible = false
	aplly_tween_when_disappear()

func apply_tween_when_appear():
	const DURATION := 0.2
	_main_container.scale = Vector2.ZERO
	_main_container.modulate.a = 0

	var custom_tween := CustomTween.new(_main_container)
	custom_tween.tween_property(_main_container, "scale", Vector2.ONE, DURATION)
	custom_tween.parallel().tween_property(_main_container, "modulate:a", 1, DURATION)
	custom_tween.start()

	# var tween := _main_container.create_tween()
	# tween.set_trans(Tween.TRANS_SINE)
	# tween.set_ease(Tween.EASE_OUT)

	# tween.tween_property(_main_container, "scale", Vector2.ONE, DURATION)
	# tween.parallel().tween_property(_main_container, "modulate:a", 1, DURATION)

func aplly_tween_when_disappear():
	const DURATION := 0.8
	_main_container.scale = Vector2.ONE
	_main_container.modulate.a = 1

	var tween := _main_container.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(_main_container, "scale", Vector2.ZERO, DURATION)
	tween.parallel().tween_property(_main_container, "modulate:a", 0, DURATION)
