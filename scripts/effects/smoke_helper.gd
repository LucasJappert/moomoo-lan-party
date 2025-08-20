class_name SmokeHelper

# Ajustá esta región a tu sprite de “smoke puff” en el atlas:
const SMOKE_RECT: Rect2 = Rect2(896, 256, 32, 32) # ejemplo; cambiala a la que uses

static func _spawn_ps(parent: Node, pos: Vector2, duration: float, setup: Callable) -> void:
	if not is_instance_valid(parent): return

	var ps := GPUParticles2D.new()
	ps.global_position = pos
	ps.one_shot = false
	ps.local_coords = false
	ps.texture = SpritesHelper.get_texture_from_region(SMOKE_RECT)

	if setup.is_valid():
		setup.call(ps)

	parent.add_child(ps)
	ps.emitting = true

	ps.finished.connect(Callable(ps, "queue_free"), CONNECT_ONE_SHOT)

	# Timer 1 como hijo de ps (si ps muere, el timer también)
	var t1 := Timer.new()
	t1.one_shot = true
	t1.ignore_time_scale = true
	t1.process_mode = Node.PROCESS_MODE_ALWAYS
	t1.wait_time = max(duration, 0.05)
	ps.add_child(t1)

	t1.timeout.connect(func(): # esta lambda NO captura parent; sólo usa ps vía "this" scope
		if not is_instance_valid(ps): return
		ps.emitting = false

		var t2 := Timer.new()
		t2.one_shot = true
		t2.ignore_time_scale = true
		t2.process_mode = Node.PROCESS_MODE_ALWAYS
		t2.wait_time = ps.lifetime + 0.2
		ps.add_child(t2)

		t2.timeout.connect(func():
			if is_instance_valid(ps):
				ps.queue_free()
		)
		t2.start()
	)
	t1.start()


# --- Efecto 1: Smoke ascendente suave ---
static func spawn_smoke(parent: Node, pos: Vector2, duration: float, updraft: float = 3.0) -> void:
	_spawn_ps(parent, pos, duration, func(ps: GPUParticles2D):
		ps.lifetime = 1.0
		ps.amount = 80
		ps.visibility_rect = Rect2(Vector2(-220, -220), Vector2(440, 440))

		# Canvas blending
		var cim := CanvasItemMaterial.new()
		cim.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		ps.material = cim

		# Process material
		var mat := ParticleProcessMaterial.new()
		var g_strength: float = -18.0 * clamp(updraft, 0.0, 2.0)
		mat.gravity = Vector3(0, g_strength, 0)
		mat.direction = Vector3(0, -1, 0)
		mat.spread = 12.0
		mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		mat.emission_sphere_radius = 12.0
		mat.initial_velocity_min = 16.0 * updraft
		mat.initial_velocity_max = 28.0 * updraft
		mat.damping_min = 8.0
		mat.damping_max = 12.0
		mat.radial_accel_min = -1.0
		mat.radial_accel_max = 1.0
		mat.tangential_accel_min = -6.0
		mat.tangential_accel_max = 6.0
		mat.angular_velocity_min = -10.0
		mat.angular_velocity_max = 10.0
		mat.scale_min = 0.45
		mat.scale_max = 0.55

		var sc := Curve.new()
		sc.add_point(Vector2(0.00, 1.10))
		sc.add_point(Vector2(0.30, 1.00))
		sc.add_point(Vector2(1.00, 0.00))
		var sc_tex := CurveTexture.new()
		sc_tex.curve = sc
		mat.scale_curve = sc_tex

		var grad := Gradient.new()
		grad.colors = PackedColorArray([
			Color(0, 0, 0, 0.12),
			Color(0, 0, 0, 0.40),
			Color(0, 0, 0, 0.00)
		])
		grad.offsets = PackedFloat32Array([0.0, 0.20, 1.0])
		var ramp := GradientTexture1D.new()
		ramp.gradient = grad
		mat.color_ramp = ramp

		ps.process_material = mat
	)

# --- Efecto 2: Capa “sulfúrica” brillante pegada al suelo ---
static func attach_sulfur_layer(parent: Node, pos: Vector2, duration: float = 0.9) -> void:
	_spawn_ps(parent, pos, duration, func(ps: GPUParticles2D):
		ps.lifetime = 0.75
		ps.amount = 60
		ps.visibility_rect = Rect2(Vector2(-128, -128), Vector2(256, 256))

		var cim := CanvasItemMaterial.new()
		cim.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		ps.material = cim

		var mat := ParticleProcessMaterial.new()
		mat.gravity = Vector3(0, -6, 0)
		mat.direction = Vector3(0, -1, 0)
		mat.spread = 60.0
		mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		mat.emission_box_extents = Vector3(14, 6, 0)
		mat.initial_velocity_min = 6.0
		mat.initial_velocity_max = 12.0
		mat.damping_min = 14.0
		mat.damping_max = 20.0
		mat.scale_min = 0.35
		mat.scale_max = 0.6

		var sc := Curve.new()
		sc.add_point(Vector2(0.00, 0.30))
		sc.add_point(Vector2(0.35, 0.90))
		sc.add_point(Vector2(1.00, 0.00))
		var sc_tex := CurveTexture.new()
		sc_tex.curve = sc
		mat.scale_curve = sc_tex

		var g := Gradient.new()
		g.colors = PackedColorArray([
			Color(1.00, 0.65, 0.25, 0.25),
			Color(0.70, 0.95, 0.25, 0.35),
			Color(0.60, 0.90, 0.20, 0.00)
		])
		var gt := GradientTexture1D.new()
		gt.gradient = g
		mat.color_ramp = gt

		ps.process_material = mat
	)

static func attach_victory_aura(parent: Node, pos: Vector2, duration: float = 1.2, intensity: float = 1.0) -> void:
	# intensity escala cantidad y opacidad (1.0 = default)
	intensity = clamp(intensity, 0.25, 2.0)

	_spawn_ps(parent, pos, duration, func(ps: GPUParticles2D):
		# Partículas pegadas al suelo, vida corta
		ps.lifetime = 0.9
		ps.amount = int(70 * intensity)
		ps.visibility_rect = Rect2(Vector2(-160, -120), Vector2(320, 240))

		# Brillo “positivo”: ADD
		var cim := CanvasItemMaterial.new()
		cim.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		ps.material = cim

		var mat := ParticleProcessMaterial.new()

		# Casi sin ascenso para que quede en el piso; un toque de “respiro”
		mat.gravity = Vector3(0, -3, 0) # Y negativo = arriba (muy leve)
		mat.direction = Vector3(0, -1, 0)
		mat.spread = 40.0

		# Emisión “alfombra”
		mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		mat.emission_box_extents = Vector3(18, 6, 0)

		# Velocidad baja + damping medio → calma
		mat.initial_velocity_min = 5.0
		mat.initial_velocity_max = 10.0
		mat.damping_min = 12.0
		mat.damping_max = 18.0

		# Remolino suave y rotación para que “viva” sin ser caótica
		mat.radial_accel_min = -4.0
		mat.radial_accel_max = 4.0
		mat.tangential_accel_min = -8.0
		mat.tangential_accel_max = 8.0
		mat.angular_velocity_min = -6.0
		mat.angular_velocity_max = 6.0

		# Tamaño base
		mat.scale_min = 0.32
		mat.scale_max = 0.58

		# Bloom rápido al inicio (sensación de “liberación”) y fade
		var sc := Curve.new()
		sc.add_point(Vector2(0.00, 0.40))
		sc.add_point(Vector2(0.22, 1.00))
		sc.add_point(Vector2(1.00, 0.00))
		var sc_tex := CurveTexture.new()
		sc_tex.curve = sc
		mat.scale_curve = sc_tex

		# 🎨 Dorado → blanco cálido → transparente (con alpha escalada por intensidad)
		var a0 := 0.24 * intensity
		var a1 := 0.30 * intensity
		var a2 := 0.00
		var g := Gradient.new()
		g.colors = PackedColorArray([
			Color(1.00, 0.90, 0.55, a0), # dorado suave (calidez/éxito)
			Color(1.00, 0.98, 0.90, a1), # blanco cálido (sensación de bienestar)
			Color(1.00, 0.98, 0.90, a2) # se apaga
		])
		g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
		var gt := GradientTexture1D.new()
		gt.gradient = g
		mat.color_ramp = gt

		ps.process_material = mat
	)

static func spawn_volcanic_sparks(parent: Node, pos: Vector2, duration: float = 0.6) -> void:
	if not is_instance_valid(parent):
		return

	var ps := GPUParticles2D.new()
	ps.global_position = pos

	# Emisión continua; cortamos a los `duration` segundos
	ps.one_shot = false

	# Lifetime fijo por partícula (corto) para limitar cuánto llegan a subir
	ps.lifetime = 0.5
	ps.preprocess = 0.0
	ps.local_coords = false
	ps.amount = 80
	ps.texture = SpritesHelper.get_texture_from_region(SMOKE_RECT) # textura blanca redonda
	ps.visibility_rect = Rect2(Vector2(-160, -160), Vector2(320, 320))

	# Brillo: ADD
	var cim := CanvasItemMaterial.new()
	cim.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ps.material = cim

	var mat := ParticleProcessMaterial.new()

	# Mantiene “hacia arriba” pero menos agresivo para no ganar tanta altura
	mat.gravity = Vector3(0, -12, 0)
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 45.0

	# Sigue saliendo “desde un punto” (o mini esfera) para efecto volcánico
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 6.0

	# Velocidad inicial alta pero recortada, con damping mayor
	mat.initial_velocity_min = 36.0
	mat.initial_velocity_max = 72.0
	mat.damping_min = 26.0
	mat.damping_max = 36.0

	# Aceleraciones caóticas, suavecitas para chisporroteo sin deriva excesiva
	mat.radial_accel_min = -8.0
	mat.radial_accel_max = 8.0
	mat.tangential_accel_min = -12.0
	mat.tangential_accel_max = 12.0

	# Chispas pequeñas
	mat.scale_min = 0.15
	mat.scale_max = 0.30

	# Se encienden fuerte y se apagan rápido
	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 1.00))
	sc.add_point(Vector2(0.60, 0.65))
	sc.add_point(Vector2(1.00, 0.00))
	var sc_tex := CurveTexture.new()
	sc_tex.curve = sc
	mat.scale_curve = sc_tex

	# Rojo -> naranja -> apagado
	var g := Gradient.new()
	g.colors = PackedColorArray([
		Color(1.0, 0.20, 0.00, 1.00),
		Color(1.0, 0.60, 0.00, 0.80),
		Color(0.40, 0.20, 0.00, 0.00)
	])
	var gt := GradientTexture1D.new()
	gt.gradient = g
	mat.color_ramp = gt

	ps.process_material = mat
	parent.add_child(ps)
	ps.emitting = true

	# Timer para cortar la emisión según `duration`
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = max(duration, 0.05)
	parent.add_child(t)

	# Liberar el nodo cuando terminen las últimas partículas
	ps.finished.connect(Callable(ps, "queue_free"), CONNECT_ONE_SHOT)

	t.timeout.connect(func():
		ps.emitting = false
	)
	t.start()

static func attach_arcane_layer(parent: Node, pos: Vector2, duration: float = 0.9) -> void:
	if not is_instance_valid(parent):
		return

	var ps := GPUParticles2D.new()
	ps.global_position = pos

	# Emisión continua; cortamos a los `duration` segs
	ps.one_shot = false

	# Lifetime corto por partícula (capa pegada al piso)
	ps.lifetime = 0.8
	ps.preprocess = 0.0
	ps.local_coords = false
	ps.amount = 70
	ps.texture = SpritesHelper.get_texture_from_region(SMOKE_RECT)
	ps.visibility_rect = Rect2(Vector2(-128, -128), Vector2(256, 256))

	# Glow místico (aditivo)
	var cim := CanvasItemMaterial.new()
	cim.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ps.material = cim

	var mat := ParticleProcessMaterial.new()

	# Leve empuje hacia arriba (muy controlado)
	mat.gravity = Vector3(0, -5, 0)

	# Dirección y apertura
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 55.0

	# “Alfombra” baja (box plano)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(16, 6, 0) # ancho x alto bajos

	# Velocidad baja + damping alto → poco desplazamiento vertical
	mat.initial_velocity_min = 5.0
	mat.initial_velocity_max = 11.0
	mat.damping_min = 14.0
	mat.damping_max = 20.0

	# Suave remolino para que respire un poco
	mat.radial_accel_min = -6.0
	mat.radial_accel_max = 6.0
	mat.tangential_accel_min = -10.0
	mat.tangential_accel_max = 10.0
	mat.angular_velocity_min = -8.0
	mat.angular_velocity_max = 8.0

	# Tamaño base
	mat.scale_min = 0.34
	mat.scale_max = 0.58

	# Escala: rápido a grande, luego se disipa
	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 0.35))
	sc.add_point(Vector2(0.30, 0.95))
	sc.add_point(Vector2(1.00, 0.00))
	var sc_tex := CurveTexture.new()
	sc_tex.curve = sc
	mat.scale_curve = sc_tex

	# 🎨 Indigo (#4B0082) → BlueViolet → Turquesa → transparente
	var g := Gradient.new()
	g.colors = PackedColorArray([
		Color(0.294, 0.000, 0.510, 0.25), # índigo suave
		Color(0.541, 0.169, 0.886, 0.35), # violeta brillante
		Color(0.251, 0.878, 0.816, 0.22), # turquesa etéreo
		Color(0.251, 0.878, 0.816, 0.00) # se apaga
	])
	g.offsets = PackedFloat32Array([0.0, 0.35, 0.70, 1.0])
	var gt := GradientTexture1D.new()
	gt.gradient = g
	mat.color_ramp = gt

	ps.process_material = mat
	parent.add_child(ps)

	# Empezar a emitir
	ps.emitting = true

	# Cortar emisión al cumplirse `duration`; liberar cuando mueran las últimas partículas
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = max(duration, 0.05)
	parent.add_child(t)

	ps.finished.connect(Callable(ps, "queue_free"), CONNECT_ONE_SHOT)

	t.timeout.connect(func():
		ps.emitting = false
	)
	t.start()

static func spawn_volcanic_layer(parent: Node, pos: Vector2, duration: float = 0.9) -> void:
	if not is_instance_valid(parent):
		return

	var ps := GPUParticles2D.new()
	ps.global_position = pos

	# Continuous emission; stop after `duration`
	ps.one_shot = false

	# Short per-particle lifetime to keep it near the ground
	ps.lifetime = 0.8
	ps.preprocess = 0.0
	ps.local_coords = false
	ps.amount = 70
	ps.texture = SpritesHelper.get_texture_from_region(SMOKE_RECT)
	ps.visibility_rect = Rect2(Vector2(-128, -128), Vector2(256, 256))

	# Volcanic glow (additive)
	var cim := CanvasItemMaterial.new()
	cim.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ps.material = cim

	var mat := ParticleProcessMaterial.new()

	# Gentle updraft so it "breathes" without climbing too high
	mat.gravity = Vector3(0, -5, 0)

	# Spread and flat "carpet" emission
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 58.0
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(16, 6, 0) # wide and thin

	# Low velocity + higher damping → stays low, shimmers
	mat.initial_velocity_min = 7.0
	mat.initial_velocity_max = 13.0
	mat.damping_min = 14.0
	mat.damping_max = 22.0

	# Subtle swirl
	mat.radial_accel_min = -6.0
	mat.radial_accel_max = 6.0
	mat.tangential_accel_min = -10.0
	mat.tangential_accel_max = 10.0
	mat.angular_velocity_min = -8.0
	mat.angular_velocity_max = 8.0

	# Particle size
	mat.scale_min = 0.34
	mat.scale_max = 0.60

	# Scale over life: quick bloom then fade
	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 0.32))
	sc.add_point(Vector2(0.30, 0.95))
	sc.add_point(Vector2(1.00, 0.00))
	var sc_tex := CurveTexture.new()
	sc_tex.curve = sc
	mat.scale_curve = sc_tex

	# 🔥 Deep red → hot orange → ember → transparent
	var g := Gradient.new()
	g.colors = PackedColorArray([
		Color(1.00, 0.16, 0.00, 0.28), # lava red
		Color(1.00, 0.55, 0.00, 0.36), # hot orange
		Color(1.00, 0.86, 0.48, 0.18), # ember glow
		Color(1.00, 0.86, 0.48, 0.00) # fades out
	])
	g.offsets = PackedFloat32Array([0.0, 0.35, 0.75, 1.0])
	var gt := GradientTexture1D.new()
	gt.gradient = g
	mat.color_ramp = gt

	ps.process_material = mat
	parent.add_child(ps)

	# Start emitting
	ps.emitting = true

	# Stop emission after `duration`; free when last particles die
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = max(duration, 0.05)
	parent.add_child(t)

	ps.finished.connect(Callable(ps, "queue_free"), CONNECT_ONE_SHOT)

	t.timeout.connect(func():
		ps.emitting = false
	)
	t.start()

# Burst doble para despertar (billow + wisps), con ancho controlado
static func spawn_awaken_smoke_burst(
	parent: Node,
	pos: Vector2,
	lifetime: float = 1.6,
	scale_factor: float = 1.0,
	intensity: float = 1.0,
	width_pixels: float = 64.0
) -> void:
	lifetime = clamp(lifetime, 0.5, 5.0)
	scale_factor = clamp(scale_factor, 0.6, 2.5)
	intensity = clamp(intensity, 0.5, 3.0)
	width_pixels = max(8.0, width_pixels)

	_spawn_ps(parent, pos, 1.8, func(ps: GPUParticles2D) -> void:
		_config_awaken_billow(ps, lifetime, scale_factor, intensity, width_pixels)
	)

	_spawn_ps(parent, pos, 1.6, func(ps: GPUParticles2D) -> void:
		_config_awaken_wisps(ps, lifetime, scale_factor, intensity, width_pixels)
	)


# ---------------- helpers de configuración ----------------

# Humo base (billow denso) del despertar — franja controlada por width_pixels
static func _config_awaken_billow(
	ps: GPUParticles2D,
	lifetime: float,
	scale_factor: float,
	intensity: float,
	width_pixels: float = 64.0
) -> void:
	scale_factor = clamp(scale_factor, 0.6, 2.5)
	intensity = clamp(intensity, 0.5, 3.0)

	ps.one_shot = true
	ps.lifetime = max(lifetime, 0.1)
	ps.amount = int(220 * intensity) # un poco menos para banda fina

	# Visibilidad: algo más ancha que el emisor + margen vertical
	var vis_w := width_pixels * 1.6 * scale_factor
	var vis_h := 320.0 * scale_factor
	ps.visibility_rect = Rect2(Vector2(-vis_w * 0.5, -vis_h * 0.5), Vector2(vis_w, vis_h))

	var cim := CanvasItemMaterial.new()
	cim.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	ps.material = cim

	var mat := ParticleProcessMaterial.new()
	mat.gravity = Vector3(0, -10.0, 0)
	mat.direction = Vector3(0, -1, 0)

	# Menor apertura para que no se desborde del ancho
	mat.spread = 35.0

	# Emisión en franja: half-extents X = width/2
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(width_pixels * 0.5 * scale_factor, 18.0 * scale_factor, 0.0)

	# Velocidades más contenidas, frenado rápido
	mat.initial_velocity_min = 70.0 * scale_factor
	mat.initial_velocity_max = 110.0 * scale_factor
	mat.damping_min = 20.0
	mat.damping_max = 28.0

	# Turbulencias bajitas para no “engordar” la franja
	mat.radial_accel_min = -8.0
	mat.radial_accel_max = 8.0
	mat.tangential_accel_min = -12.0
	mat.tangential_accel_max = 12.0
	mat.angular_velocity_min = -12.0
	mat.angular_velocity_max = 12.0

	# Tamaño de partícula
	mat.scale_min = 0.55 * scale_factor
	mat.scale_max = 0.95 * scale_factor

	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 0.20))
	sc.add_point(Vector2(0.16, 1.00))
	sc.add_point(Vector2(1.00, 0.00))
	var sc_tex := CurveTexture.new()
	sc_tex.curve = sc
	mat.scale_curve = sc_tex

	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(0.06, 0.06, 0.06, 0.42 * intensity),
		Color(0.09, 0.09, 0.09, 0.28 * intensity),
		Color(0.09, 0.09, 0.09, 0.00)
	])
	grad.offsets = PackedFloat32Array([0.0, 0.36, 1.0])
	var ramp := GradientTexture1D.new()
	ramp.gradient = grad
	mat.color_ramp = ramp

	ps.process_material = mat

# Hebras finas (wisps) — siguen la misma franja
static func _config_awaken_wisps(
	ps: GPUParticles2D,
	lifetime: float,
	scale_factor: float,
	intensity: float,
	width_pixels: float = 64.0
) -> void:
	scale_factor = clamp(scale_factor, 0.6, 2.5)
	intensity = clamp(intensity, 0.5, 3.0)

	ps.one_shot = true
	ps.lifetime = max(lifetime * 0.85, 0.1)
	ps.amount = int(120 * intensity)

	var vis_w := width_pixels * 1.6 * scale_factor
	var vis_h := 280.0 * scale_factor
	ps.visibility_rect = Rect2(Vector2(-vis_w * 0.5, -vis_h * 0.5), Vector2(vis_w, vis_h))

	var cim := CanvasItemMaterial.new()
	cim.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	ps.material = cim

	var mat := ParticleProcessMaterial.new()
	mat.gravity = Vector3(0, -8.0, 0)
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 25.0

	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(width_pixels * 0.5 * scale_factor, 12.0 * scale_factor, 0.0)

	mat.initial_velocity_min = 55.0 * scale_factor
	mat.initial_velocity_max = 95.0 * scale_factor
	mat.damping_min = 16.0
	mat.damping_max = 24.0

	mat.radial_accel_min = -6.0
	mat.radial_accel_max = 6.0
	mat.tangential_accel_min = -10.0
	mat.tangential_accel_max = 10.0
	mat.angular_velocity_min = -10.0
	mat.angular_velocity_max = 10.0

	mat.scale_min = 0.38 * scale_factor
	mat.scale_max = 0.68 * scale_factor

	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 0.12))
	sc.add_point(Vector2(0.14, 0.95))
	sc.add_point(Vector2(1.00, 0.00))
	var sc_tex := CurveTexture.new()
	sc_tex.curve = sc
	mat.scale_curve = sc_tex

	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(0.12, 0.12, 0.12, 0.34 * intensity),
		Color(0.12, 0.12, 0.12, 0.20 * intensity),
		Color(0.12, 0.12, 0.12, 0.00)
	])
	grad.offsets = PackedFloat32Array([0.0, 0.40, 1.0])
	var ramp := GradientTexture1D.new()
	ramp.gradient = grad
	mat.color_ramp = ramp

	ps.process_material = mat
