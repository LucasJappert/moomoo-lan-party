extends Node
class_name ParticleTrailHelper

const MIN_LIFETIME := 0.05
const SMOKE_RECT: Rect2 = Rect2(896, 256, 32, 32) # ejemplo; cambiala a la que uses

# projectile -> { emitter, lifetime, forward_offset, base_rate, amplitude }
static var _by_projectile: Dictionary = {}
static var _shared_scale_curve: CurveTexture
static var _shared_color_ramp: GradientTexture1D

static func _ensure_shared_resources() -> void:
	if _shared_scale_curve and _shared_color_ramp:
		return
	# Scale over life (1 -> 0)
	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 1.00))
	sc.add_point(Vector2(1.00, 0.00))
	_shared_scale_curve = CurveTexture.new()
	_shared_scale_curve.curve = sc

	# Color over life: blanco (usa modulate) -> negro transparente
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(1, 1, 1, 1.0),
		Color(0, 0, 0, 0.0)
	])
	_shared_color_ramp = GradientTexture1D.new()
	_shared_color_ramp.gradient = grad

static func attach_to_projectile(projectile: Projectile, color_supplier: Callable = Callable()) -> void:
	projectile.trail_enabled = true
	if _by_projectile.has(projectile) and is_instance_valid(_by_projectile[projectile].emitter):
		return

	_ensure_shared_resources()

	# Params desde Projectile
	var lifetime: float = max(projectile.trail_lifetime, MIN_LIFETIME)
	var amplitude: float = float(projectile.trail_amplitude)
	var base_rate: float = float(projectile.trail_emission_rate) # partículas/seg (objetivo)
	var particle_scale: float = float(projectile.trail_scale)
	var forward_offset: float = float(projectile.trail_forward_offset)
	var start_color: Color = projectile.trail_start_color
	var texture: Texture2D = projectile.trail_texture
	if texture == null: texture = SpritesHelper.get_texture_from_region(SMOKE_RECT)

	# Color base (por proyectil)
	if color_supplier.is_valid():
		var res = color_supplier.call(projectile)
		if typeof(res) == TYPE_COLOR:
			start_color = res

	# Emitter
	var emitter := GPUParticles2D.new()
	emitter.name = "ProjectileTrail"
	emitter.local_coords = false
	emitter.one_shot = false
	emitter.lifetime = lifetime
	emitter.fixed_fps = 30 # ↓ costo de update
	emitter.visibility_rect = Rect2(-amplitude - 12.0, -12.0, amplitude * 2.0 + 24.0, 24.0)
	if texture:
		emitter.texture = texture

	# Material (uno por emisor, pero compartiendo texturas carísimas)
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0) # lateral; el nodo rota con la flecha
	pm.spread = 20.0
	pm.initial_velocity_min = - amplitude / lifetime
	pm.initial_velocity_max = amplitude / lifetime
	pm.gravity = Vector3.ZERO
	pm.damping_min = 0.0
	pm.damping_max = 0.0
	pm.scale_min = particle_scale
	pm.scale_max = particle_scale

	# Color por partícula: base neutro + variación de tono + modulate del emisor
	pm.color = Color(1, 1, 1, 1.0) # base neutro; el color lo da emitter.modulate
	var hue_width := 0.08
	pm.hue_variation_min = - hue_width
	pm.hue_variation_max = hue_width
	var hue_curve := Curve.new()
	hue_curve.add_point(Vector2(0.0, 1.0))
	hue_curve.add_point(Vector2(1.0, 1.0))
	var hue_tex := CurveTexture.new()
	hue_tex.curve = hue_curve
	pm.hue_variation_curve = hue_tex

	# Texturas compartidas (evita crear N rampas/curvas)
	pm.scale_curve = _shared_scale_curve
	pm.color_ramp = _shared_color_ramp

	emitter.process_material = pm

	# Densidad: setear UNA VEZ. (No cambiarla cada frame)
	emitter.amount = max(1, int(round(base_rate * lifetime)))

	# Color base del proyectil vía modulate (incluye alpha)
	emitter.modulate = start_color

	# Parent + comenzar
	var parent := projectile.get_parent()
	if parent == null:
		parent = projectile.get_tree().current_scene
	parent.add_child(emitter)
	emitter.emitting = true

	_sync_emitter_transform(emitter, projectile, forward_offset)

	_by_projectile[projectile] = {
		"emitter": emitter,
		"lifetime": float(lifetime),
		"forward_offset": float(forward_offset),
		"base_rate": float(base_rate),
		"amplitude": float(amplitude)
	}

	if not projectile.is_connected("tree_exited", Callable(ParticleTrailHelper, "_on_projectile_tree_exited")):
		projectile.connect("tree_exited", Callable(ParticleTrailHelper, "_on_projectile_tree_exited").bind(projectile))

static func process_one(projectile: Projectile, _delta: float) -> void:
	if not _by_projectile.has(projectile): return
	var data = _by_projectile[projectile]
	var emitter: GPUParticles2D = data.emitter
	if not is_instance_valid(emitter): return

	_sync_emitter_transform(emitter, projectile, float(data.forward_offset))

static func detach_from_projectile(projectile: Projectile, fade_duration: float = 0.0) -> void:
	if not _by_projectile.has(projectile): return
	var data = _by_projectile[projectile]
	var emitter: GPUParticles2D = data.emitter
	_by_projectile.erase(projectile)
	if not is_instance_valid(emitter): return

	if fade_duration > 0.0:
		# Fade visual del emisor (alpha), sin tocar amount
		var tween := emitter.create_tween()
		tween.tween_property(emitter, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(func():
			emitter.emitting = false
			# esperar a que mueran las partículas ya emitidas
			var t := Timer.new()
			t.one_shot = true
			t.wait_time = float(data.lifetime) + 0.1
			emitter.add_child(t)
			t.timeout.connect(func():
				if is_instance_valid(emitter): emitter.queue_free()
			)
			t.start()
		)
	else:
		emitter.emitting = false
		var t2 := Timer.new()
		t2.one_shot = true
		t2.wait_time = float(data.lifetime) + 0.1
		emitter.add_child(t2)
		t2.timeout.connect(func():
			if is_instance_valid(emitter): emitter.queue_free()
		)
		t2.start()

static func _sync_emitter_transform(emitter: GPUParticles2D, projectile: Projectile, forward_offset: float) -> void:
	var forward := Vector2.RIGHT.rotated(projectile.global_rotation)
	emitter.global_position = projectile.global_position + forward * forward_offset
	emitter.rotation = projectile.global_rotation

static func _on_projectile_tree_exited(projectile: Projectile) -> void:
	detach_from_projectile(projectile, 0.1)
