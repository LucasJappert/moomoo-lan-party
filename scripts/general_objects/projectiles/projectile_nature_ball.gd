class_name ProjectileNatureBall

extends ProjectileBase

const NAME = "nature_ball"
const RECT_REGION := Rect2(Vector2(128, 288), Vector2(32, 32))
const SPEED: float = 300
const SCALE: float = 1.2
const VOLUME: float = -10

static func try_init(_projectile: Projectile):
	if _projectile.type != NAME: return

	_projectile.speed = SPEED
	set_frames(_projectile, [RECT_REGION])
	_projectile.sprite.play("default")
	# _projectile.sprite.scale = Vector2(1.1, 1.1)
	SoundsHelper.play_projectile_hit(_projectile.type, VOLUME)


static func actions_while_flying(_projectile: Projectile):
	if NAME != _projectile.type: return
	for i in range(4):
		var spawn_position = Vector2(randf_range(-4, 4), randf_range(-4, 4))
		var particle_sprite := SpritesHelper.get_sprite_2d(RECT_REGION)
		particle_sprite.rotation = _projectile.rotation
		ParticleEffects.spawn_sprite(
			GameManager.game_world.general_container,
			_projectile.global_position + spawn_position,
			particle_sprite,
			0.3,
			Color(0, 0, 0, 0)
		)


static func actions_on_reaching_target(_projectile: Projectile) -> void:
	if NAME != _projectile.type: return

	var target = _projectile.get_target_entity()
	SoundsHelper.play_sfx("res://sounds/hits/demon_bolt_impact.wav", VOLUME, 2)

	if target: return _spawn_explosion(Vector2.ZERO, target.projectile_zone)

	_spawn_explosion(_projectile.global_position, GameManager.game_world.over_terrain_layer_layer_2)

static func _get_random_color() -> Color:
	return Color.from_hsv(
		randf_range(0.25, 0.42), # Hue: verdes
		randf_range(0.6, 1.0), # Saturación: intenso
		randf_range(0.2, 0.5), # Luminosidad: oscuro a medio
		1.0 # Alpha fijo, opaco
	)

const PARTICLE_RECT := Rect2(272, 272, 16, 16)
static func _spawn_explosion(position: Vector2, parent: Node2D) -> void:
	var speed_range: Vector2 = Vector2(4, 32)
	var lifetime: float = 0.5
	for i in 5:
		var particle := SpritesHelper.get_sprite_2d(PARTICLE_RECT)
		particle.position = position
		particle.modulate = _get_random_color()
		particle.scale = Vector2.ONE
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
		tween.parallel().tween_property(particle, "scale", Vector2.ZERO, particle_lifetime).set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(particle, "rotation", TAU, particle_lifetime).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(particle.queue_free)
