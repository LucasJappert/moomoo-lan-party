class_name ProjectileDemonBolt

extends ProjectileBase

const NAME = "demon_bolt"
const BALL_RECT: Rect2 = Rect2(448, 288, 32, 32)
const SPEED: float = 300
const SCALE: float = 1
const VOLUME: float = -15
const PARTICLE_RECT := Rect2(272, 272, 16, 16)

static func try_init(p: Projectile) -> void:
	if p.type != NAME:
		return

	p.speed = SPEED
	p.sprite.visible = false

	p.set_meta("osc_t", 0.0)

	var balls_container := Node2D.new()
	p.general_objects_container.add_child(balls_container)
	p.set_meta("osc_container", balls_container)

	var balls: Array = []
	for i in range(2):
		var node := Node2D.new()
		balls_container.add_child(node)

		var spr := SpritesHelper.get_sprite_2d(BALL_RECT)
		spr.scale = Vector2(0.5, 0.5)
		# opcional: asegurar que queden por encima si hace falta
		spr.z_index = p.sprite.z_index + 1
		node.add_child(spr)

		var tail := _make_tail_emitter(_get_random_color())
		tail.local_coords = false # estela queda “pegada” al mundo
		node.add_child(tail)
		tail.emitting = true

		var dir := 1
		if i == 0: dir = 1
		else: dir = -1

		balls.append({
			"node": node,
			"sprite": spr,
			"dir": dir,
			"tail": tail,
		})

	p.set_meta("osc_balls", balls)

	# sonido al iniciar (como tenías)
	SoundsHelper.play_sfx("res://sounds/hits/demon_bolt_start.wav", VOLUME, 2)

static func actions_while_flying(p: Projectile) -> void:
	if p.type != NAME:
		return
	if not p.has_meta("osc_balls"):
		return

	const AMPLITUDE := 8.0
	const FREQ := 2.0 # Hz

	var t := float(p.get_meta("osc_t"))
	t += GameManager.get_process_delta_time()
	p.set_meta("osc_t", t)

	var base_offset := sin(t * TAU * FREQ) * AMPLITUDE

	var balls = p.get_meta("osc_balls")
	for data in balls:
		var node: Node2D = data["node"]
		var dir: int = data["dir"]
		node.position = Vector2(0, base_offset * dir)

static func cleanup(p: Projectile) -> void:
	# Detener emisión y liberar contenedor si existe
	if p.has_meta("osc_balls"):
		var balls = p.get_meta("osc_balls")
		for data in balls:
			var tail: GPUParticles2D = data.get("tail")
			if is_instance_valid(tail):
				tail.emitting = false

	if p.has_meta("osc_container"):
		var cont: Node = p.get_meta("osc_container")
		if is_instance_valid(cont):
			cont.queue_free()

	p.set_meta("osc_balls", null)
	p.set_meta("osc_container", null)
	p.set_meta("osc_t", 0.0)

static func _make_tail_emitter(base_color: Color) -> GPUParticles2D:
	var ps := GPUParticles2D.new()
	ps.amount = 48
	ps.lifetime = 0.15
	ps.one_shot = false
	ps.local_coords = false

	# IMPORTANTE: textura visible (usá una bolita suave de tu atlas; BALL_RECT si te sirve)
	ps.texture = SpritesHelper.get_texture_from_region(BALL_RECT)
	# Rect de visibilidad generoso (porque local_coords=false deja “pintadas” en el mundo)
	ps.visibility_rect = Rect2(Vector2(-96, -96), Vector2(192, 192))
	# Opcional: asegurar arriba/debajo de otros
	# ps.z_index = 100

	var mat := ParticleProcessMaterial.new()
	# En Godot 4: Vector3 aunque sea 2D
	mat.gravity = Vector3(0, 0, 0)
	mat.direction = Vector3(1, 0, 0)
	mat.spread = 360.0

	mat.initial_velocity_min = 10.0
	mat.initial_velocity_max = 40.0
	# Damping en Godot 4
	mat.damping_min = 20.0
	mat.damping_max = 20.0

	# Con textura, subí el tamaño para que se note
	mat.scale_min = 0.15
	mat.scale_max = 0.25

	# Desvanecido a transparente
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		base_color,
		Color(base_color.r, base_color.g, base_color.b, 0.0)
	])
	var ramp := GradientTexture1D.new()
	ramp.gradient = grad
	mat.color_ramp = ramp

	# “Cola” ya nacida al comienzo (opcional)
	ps.preprocess = ps.lifetime * 0.9

	ps.process_material = mat
	return ps


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
