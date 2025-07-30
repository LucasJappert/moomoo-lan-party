class_name ProjectileDemonBolt

extends ProjectileBase

const NAME = "demon_bolt"
const BALL_RECT: Rect2 = Rect2(448, 288, 32, 32)
const SPEED: float = 300
const SCALE: float = 1
const VOLUME: float = -15
const PARTICLE_RECT := Rect2(272, 272, 16, 16)


static func try_launch(_proj_type: String, _entity: Entity, _target: Entity, _damage: int) -> bool:
	if _proj_type != NAME: return false

	Projectile.launch(_entity, _target, _damage)
	return true

static func try_init(_projectile: Projectile):
	if _projectile.type != NAME: return

	_projectile.speed = SPEED
	_projectile.sprite.visible = false
	_projectile.set_meta("oscillating_balls", [])
	_projectile.set_meta("oscillation_time", 0.0)


	var balls_container := Node2D.new()
	var radius := 8

	var balls_array = _projectile.get_meta("oscillating_balls")
	for i in range(2):
		var sprite := SpritesHelper.get_sprite_2d(BALL_RECT)
		sprite.scale = Vector2.ONE * 0.5
		sprite.position = Vector2(0, 0) # posición inicial
		sprite.modulate = Color(1, 1, 1, 1)

		# Movimiento senoidal en direcciones opuestas
		var direction := 1 if i == 0 else -1
		var tween := sprite.create_tween()
		var amplitude := radius
		var duration := 0.5
		sprite.z_index = 20 + direction

		tween.set_loops()
		tween.tween_method(func(t):
			var offset := sin(t * TAU) * amplitude * direction
			sprite.position = Vector2(0, offset)
		, 0.0, 1.0, duration)

		balls_container.add_child(sprite)
		balls_array.append({"sprite": sprite, "dir": 1 if i == 0 else -1})

	# Agregamos las bolas al contenedor principal
	_projectile.general_objects_container.add_child(balls_container)
	SoundsHelper.play_sfx("res://sounds/hits/demon_bolt_start.wav", VOLUME, 2)
	
static func actions_while_flying(_projectile: Projectile):
	if NAME != _projectile.type: return
	const TAIL_RADIUS := 3.0
	const AMPLITUDE := 8.0

	var time: float = _projectile.get_meta("oscillation_time")
	time += GameManager.get_process_delta_time()
	_projectile.set_meta("oscillation_time", time)

	if not _projectile.has_meta("oscillating_balls"): return

	for data in _projectile.get_meta("oscillating_balls"):
		var sprite = data["sprite"]
		var dir = data["dir"]
		var offset_y = sin(time * TAU * 2) * AMPLITUDE * dir
		sprite.position = Vector2(0, offset_y)

		for i in range(10):
			var spawn_position = Vector2(randf_range(-TAIL_RADIUS, TAIL_RADIUS), randf_range(-TAIL_RADIUS, TAIL_RADIUS))
			ParticleEffects.spawn(
				sprite.global_position + spawn_position,
				GameManager.game_world.general_container,
				0.2,
				_get_random_color(),
				0.3
			)


static func actions_on_reaching_target(_projectile: Projectile) -> void:
	if NAME != _projectile.type: return

	var target = _projectile.get_target_entity()
	SoundsHelper.play_sfx("res://sounds/hits/demon_bolt_impact.wav", VOLUME, 2)

	if target: return _spawn_explosion(Vector2.ZERO, target.projectile_zone)

	_spawn_explosion(_projectile.global_position, GameManager.game_world.over_terrain_layer_layer_2)

static func _get_random_color() -> Color:
	return Color.from_hsv(randf_range(0.5, 0.7), randf_range(0.6, 1), randf_range(0.3, 0.6), randf_range(0.6, 1))

static func _spawn_explosion(position: Vector2, parent: Node2D) -> void:
	var speed_range: Vector2 = Vector2(4, 32)
	var lifetime: float = 0.5
	for i in 20:
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
