extends Node
class_name FireEffect

const FIRE_REGION := Rect2(160, 256, 32, 32)
const WIDTH_BOX_SPAWN := 16

static func spawn_fire_effect(parent: Node, p_position: Vector2, duration: float = 0, scale_factor: float = 1.0) -> GPUParticles2D:
	var texture := SpritesHelper.get_texture_from_region(FIRE_REGION)
	var particles := _create_fire_particles(texture, p_position, scale_factor)
	parent.add_child(particles)

	if duration > 0.0:
		var remover := FireRemover.new()
		remover.setup(particles, duration)
		parent.add_child(remover)

	return particles


static func _create_fire_particles(texture: Texture2D, position: Vector2, scale_factor: float = 1.0) -> GPUParticles2D:
	var particles := GPUParticles2D.new()
	particles.position = Vector2(position.x - WIDTH_BOX_SPAWN * 0.5 * scale_factor, position.y)
	particles.texture = texture
	particles.amount = 50
	particles.lifetime = 0.8
	particles.one_shot = false
	particles.preprocess = 0.0
	particles.speed_scale = 1.0
	particles.local_coords = true
	particles.rotation_degrees = 90

	var material := ParticleProcessMaterial.new()
	material.initial_velocity = Vector2(0, -96.0)
	# material.linear_accel = Vector2(-120.0, 0.0)
	material.angle = Vector2(0.0, 0.0)
	material.gravity = Vector3(0, 0, 0)
	material.scale = Vector2(0.4, 0.4) * scale_factor
	material.direction = Vector3(1, 0, 1)
	material.spread = 20.0
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(2, WIDTH_BOX_SPAWN * 0.25 * scale_factor, 0)
	material.scale_curve = _generate_scale_curve_texture()
	material.color_ramp = _generate_alpha_only_ramp()
	particles.process_material = material

	return particles


static func _generate_alpha_only_ramp() -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.add_point(0, Color(1, 1, 1, 1)) # Arranca normal
	gradient.add_point(0.6, Color(0.0, 0.0, 0.0, 0.3)) # Se hace negro mientras se vuelve transparente
	gradient.add_point(0.99, Color(0, 0, 0, 0.05))
	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	return ramp


static func _generate_scale_curve_texture() -> CurveTexture:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0))
	curve.add_point(Vector2(0.2, 1.0))
	curve.add_point(Vector2(1.0, 0.1))

	var curve_texture := CurveTexture.new()
	curve_texture.curve = curve
	return curve_texture

static func stop_effect(particles: GPUParticles2D) -> void:
	if not is_instance_valid(particles):
		return
	particles.emitting = false

	# Creamos un temporizador interno para eliminar las partículas luego de su lifetime
	var timer := Timer.new()
	timer.wait_time = particles.lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(particles, "queue_free"))
	particles.add_child(timer)
	timer.start()

# 🔥 Nodo interno para eliminar el fuego automáticamente
class FireRemover:
	extends Node

	var particles: GPUParticles2D
	var duration := 1.0
	var elapsed := 0.0
	var waiting_to_free := false

	func setup(p_particles: GPUParticles2D, p_duration: float) -> void:
		particles = p_particles
		duration = p_duration
		set_process(true)

	func _process(delta: float) -> void:
		if waiting_to_free:
			return

		elapsed += delta
		if elapsed >= duration:
			waiting_to_free = true
			if is_instance_valid(particles):
				particles.emitting = false
				# Creamos un Timer manualmente para no usar `await`
				var timer := Timer.new()
				timer.wait_time = particles.lifetime
				timer.one_shot = true
				timer.connect("timeout", Callable(self, "_on_timeout"))
				add_child(timer)
				timer.start()
			else:
				queue_free()

	func _on_timeout():
		if is_instance_valid(particles):
			particles.queue_free()
		queue_free()