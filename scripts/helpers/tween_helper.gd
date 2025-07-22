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

static func apply_scaling_pulse(
	sprite: Node2D,
	tween: Tween,
	scale_min := 0.9,
	scale_max := 1.0,
	duration := 0.2,
) -> Tween:
	sprite.scale = Vector2.ONE * scale_max

	tween.parallel().tween_property(sprite, "scale", Vector2.ONE * scale_min, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE * scale_max, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween

static func apply_fading_pulse(
	sprite: CanvasItem,
	tween: Tween,
	alpha_min := 0.6,
	alpha_max := 1.0,
	duration := 0.3,
) -> Tween:
	sprite.modulate.a = alpha_max

	tween.parallel().tween_property(sprite, "modulate:a", alpha_min, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate:a", alpha_max, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween

static func apply_rotation_loop(
	sprite: Node2D,
	duration := 0.4,
) -> Tween:
	var tween := sprite.create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "rotation", TAU, duration).from(0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	return tween

static func apply_tween_to_property(
	p_node: Object,
	p_tween: Tween,
	p_property: String,
	p_to_value: Variant,
	p_duration: float,
	p_trans := Tween.TRANS_SINE,
	p_ease := Tween.EASE_OUT
) -> Tween:
	p_tween.parallel().tween_property(p_node, p_property, p_to_value, p_duration).set_trans(p_trans).set_ease(p_ease)
	return p_tween

static func apply_looping_tween_to_property(
	p_node: Node,
	p_property: String,
	p_from_value: Variant,
	p_to_value: Variant,
	p_duration: float,
	p_trans := Tween.TRANS_SINE,
	p_ease := Tween.EASE_IN_OUT
) -> void:
	var tween = p_node.create_tween()
	tween.set_loops() # Loop indefinido
	tween.tween_property(p_node, p_property, p_to_value, p_duration) \
		.set_trans(p_trans).set_ease(p_ease) \
		.from(p_from_value)
	tween.tween_property(p_node, p_property, p_from_value, p_duration) \
		.set_trans(p_trans).set_ease(p_ease) \
		.from(p_to_value)

static func apply_tween_to_dissolve(tween: Tween, _node: Node, TWEEN_DURATION: float) -> void:
	if not is_instance_valid(_node):
		return

	var dissolve_updater = func(value: float) -> void:
		var mat := _node.material as ShaderMaterial
		if mat:
			mat.set_shader_parameter("dissolve_amount", value)

	var track := tween.parallel().tween_method(dissolve_updater, 0.0, 1.0, TWEEN_DURATION)
	if track != null:
		track.set_trans(Tween.TRANS_LINEAR)
