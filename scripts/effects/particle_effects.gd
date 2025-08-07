class_name ParticleEffects
const RECT_REGION := Rect2(256, 256, 16, 16)

static func spawn(position: Vector2, parent: Node, lifetime: float = 1.0, color: Color = Color.WHITE, scale: float = 1) -> Sprite2D:
	var sprite := SpritesHelper.get_sprite_2d(RECT_REGION)
	sprite.global_position = position # en vez de sprite.position
	sprite.modulate = color
	sprite.scale = Vector2.ONE * scale
	parent.add_child(sprite)

	# Crear tween para desvanecerse y eliminarse
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, lifetime).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "scale", Vector2.ZERO, lifetime).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(sprite.queue_free)
	return sprite
	
static func spawn_tween_to_black(position: Vector2, parent: Node, lifetime: float = 1.0, color: Color = Color.WHITE, scale: float = 1) -> Sprite2D:
	var sprite := SpritesHelper.get_sprite_2d(RECT_REGION)
	sprite.global_position = position # en vez de sprite.position
	sprite.modulate = color
	sprite.scale = Vector2.ONE * scale
	parent.add_child(sprite)
	
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "modulate", Color(0, 0, 0), lifetime).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "scale", Vector2.ZERO, lifetime).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(sprite.queue_free)

	return sprite

static func spawn_sprite(parent: Node, position: Vector2, sprite: Sprite2D, lifetime: float = 1.0, modulate_to: Color = Color(0, 0, 0, 1)) -> void:
	sprite.global_position = position # en vez de sprite.position
	sprite.scale = Vector2.ONE * 0.5
	parent.add_child(sprite)

	# Crear tween para desvanecerse y eliminarse
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "modulate", modulate_to, lifetime).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "scale", Vector2.ZERO, lifetime).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(func():
		sprite.queue_free()
	)

const PARTICLE_RECT := Rect2(272, 272, 16, 16)
static func spawn_floating_particle(screen_size: Vector2, parent: Node, lifetime: float = 2.5) -> Sprite2D:
	var position := Vector2(randi_range(0, int(screen_size.x)), randi_range(0, int(screen_size.y)))
	var sprite := SpritesHelper.get_sprite_2d(PARTICLE_RECT)
	sprite.global_position = position
	sprite.modulate = Color(randf_range(0.8, 1.0), randf_range(0.8, 1.0), randf_range(0.0, 1), 0) # empieza invisible
	sprite.scale = Vector2.ONE * randf_range(0.5, 1.5)
	parent.add_child(sprite)

	var target_offset := Vector2(randf_range(-200, 200), randf_range(-200, 200))
	var target_position := sprite.global_position + target_offset

	var tween := sprite.create_tween()
	# Fade in al aparecer (solo al inicio)
	tween.tween_property(sprite, "modulate:a", 1, 0.5).set_trans(Tween.TRANS_SINE)
	# Movimiento continuo
	tween.parallel().tween_property(sprite, "global_position", target_position, lifetime).set_trans(Tween.TRANS_LINEAR)
	# Fade out al final
	tween.parallel().tween_property(sprite, "scale", Vector2.ZERO, 0.5).set_delay(lifetime - 0.5).set_trans(Tween.TRANS_SINE)
	# Eliminar sprite (o reiniciarlo si usás eso)
	tween.tween_callback(sprite.queue_free)
	
	# 🔁 Efecto de pulso (loop sobre alpha)
	var pulse_tween := sprite.create_tween()
	pulse_tween.set_loops() # infinito
	pulse_tween.tween_property(sprite, "modulate:a", 0.3, randf_range(0.5, 1.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(sprite, "modulate:a", 1.0, randf_range(1, 1.5)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Elegimos una velocidad aleatoria entre 5 y 15 segundos por vuelta
	var rotation_duration := randf_range(5.0, 15.0)
	# Creamos el tween de rotación infinita
	var rotate_tween := sprite.create_tween()
	rotate_tween.set_loops() # infinito
	var rotation_direction = 1 if randf() < 0.5 else -1
	rotate_tween.tween_property(sprite, "rotation", sprite.rotation + TAU * rotation_direction, rotation_duration).set_trans(Tween.TRANS_LINEAR)

	return sprite
