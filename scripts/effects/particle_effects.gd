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

static func spawn_sprite(parent: Node, position: Vector2, sprite: Sprite2D, lifetime: float = 1.0) -> void:
	sprite.global_position = position # en vez de sprite.position
	sprite.scale = Vector2.ONE * 0.5
	parent.add_child(sprite)

	# Crear tween para desvanecerse y eliminarse
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "modulate", Color(0, 0, 0, 1), lifetime).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "scale", Vector2.ZERO, lifetime).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(func():
		sprite.queue_free()
	)
