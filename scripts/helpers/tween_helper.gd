class_name TweenHelper

static func apply_pulsing_modulate_and_scale(
	sprite: AnimatedSprite2D,
	base_color := Color(1, 1, 1),
	dark_factor := 0.2,
	pulse_duration := 0.1,
	scale_min := 0.8,
	scale_max := 1.0
) -> void:
	# Color más oscuro
	var dark_color := base_color * dark_factor

	# Aplicar color y escala inicial
	sprite.modulate = base_color
	sprite.scale = Vector2.ONE * scale_max

	# Crear tween infinito
	var tween := sprite.create_tween()
	tween.set_loops()

	# Pulso de brillo
	tween.tween_property(sprite, "modulate", dark_color, pulse_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate", base_color, pulse_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Pulso de escala
	tween.parallel().tween_property(sprite, "scale", Vector2.ONE * scale_min, pulse_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE * scale_max, pulse_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)