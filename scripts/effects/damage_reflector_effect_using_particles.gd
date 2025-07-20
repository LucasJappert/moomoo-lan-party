extends Node
class_name DamageReflectorEffectUsingParticles

const ATLAS_LINE_REGION := Rect2(272, 263, 16, 2) # Línea blanca finita

static func attach_to(target: Node2D, duration: float = -1.0) -> Node2D:
	if target.has_node("DamageReflector"):
		target.get_node("DamageReflector").queue_free()

	var wrapper := Node2D.new()
	wrapper.name = "DamageReflector"
	wrapper.position = Vector2.ZERO
	target.add_child(wrapper)

	# Crear GPUParticles2D
	var particles := GPUParticles2D.new()
	particles.name = "LineParticles"
	particles.texture = SpritesHelper.get_texture_from_region(ATLAS_LINE_REGION)
	particles.amount = 80
	particles.lifetime = 0.4
	particles.one_shot = false
	particles.emitting = true
	particles.speed_scale = 1.0

	# Configuración del material de partículas
	var material := ParticleProcessMaterial.new()
	material.direction = Vector3.RIGHT # Usa Vector3 porque es sistema 3D
	material.spread = 180.0

	material.initial_velocity_min = 60.0
	material.initial_velocity_max = 120.0

	material.scale_min = 0.3
	material.scale_max = 1.2

	material.angle_min = 0.0
	material.angle_max = 360.0

	# Rampa de color para desvanecimiento
	var gradient := Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))

	var gradient_tex := GradientTexture1D.new()
	gradient_tex.gradient = gradient
	material.color_ramp = gradient_tex

	particles.process_material = material
	wrapper.add_child(particles)

	# Crear updater para manejar duración
	var updater := DamageReflectorUpdater.new()
	updater.init(duration, wrapper)
	wrapper.add_child(updater)

	return wrapper


# --- Clase interna ---
class DamageReflectorUpdater:
	extends Node2D

	var time_left := -1.0
	var wrapper_node: Node = null

	func init(_duration: float, _wrapper_node: Node):
		time_left = _duration
		wrapper_node = _wrapper_node
		set_process(true)

	func _process(delta):
		if time_left > 0.0:
			time_left -= delta
			if time_left <= 0.0:
				wrapper_node.queue_free()
