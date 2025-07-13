extends Node
class_name ParticleTrail
const RECT_REGION := Rect2(256, 256, 16, 16)

static func spawn(position: Vector2, parent: Node, lifetime: float = 1.0, color: Color = Color.WHITE, scale: float = 1) -> void:
	var sprite := SpritesHelper.get_sprite_2d(RECT_REGION)
	sprite.position = position
	sprite.modulate = color
	sprite.scale = Vector2.ONE * scale
	parent.add_child(sprite)

	# Crear tween para desvanecerse y eliminarse
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, lifetime).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(sprite.queue_free)

static func spawn_explosion(position: Vector2, parent: Node2D, amount: int = 50, color: Color = Color(1, 1, 1), lifetime: float = 0.5, speed_range: Vector2 = Vector2(4, 32), scale: float = 0.2) -> void:
	# var texture := SpritesHelper.get_texture_from_region(RECT_REGION)
	for i in amount:
		var particle := SpritesHelper.get_sprite_2d(RECT_REGION)
		particle.position = position
		# particle.texture = texture
		particle.modulate = color
		particle.scale = Vector2.ONE * scale
		parent.add_child(particle)

		# Dirección y velocidad aleatoria
		var angle := randf() * TAU
		var direction := Vector2(cos(angle), sin(angle))
		var speed := randf_range(speed_range.x, speed_range.y)
		var velocity := direction * speed
		var particle_lifetime := randf_range(lifetime * 0.5, lifetime * 1.3)

		var final_pos := particle.position + velocity * particle_lifetime
		var tween := particle.create_tween()
		tween.tween_property(particle, "position", final_pos, particle_lifetime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, particle_lifetime).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(particle.queue_free)
