class_name SmokeHelper

# Ajustá esta región a tu sprite de “smoke puff” en el atlas:
const SMOKE_RECT: Rect2 = Rect2(896, 256, 32, 32) # ejemplo; cambiala a la que uses

static func spawn_smoke(parent: Node, pos: Vector2, duration: float, updraft: float = 3.0) -> void:
	if not is_instance_valid(parent):
		return

	var ps := GPUParticles2D.new()
	ps.global_position = pos

	# Emisión continua; la cortamos a los `duration` segs
	ps.one_shot = false

	# Lifetime por partícula (fijo) → no depende de `duration`
	ps.lifetime = 1.0
	# ps.preproctess = ps.lifetime * 0.35 # pre-warm para que aparezca con “cuerpo”
	ps.local_coords = false
	ps.amount = 80
	ps.texture = SpritesHelper.get_texture_from_region(SMOKE_RECT)
	ps.visibility_rect = Rect2(Vector2(-220, -220), Vector2(440, 440))

	# Mezcla "humo" (oscurece)
	var cim := CanvasItemMaterial.new()
	cim.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	ps.material = cim

	var mat := ParticleProcessMaterial.new()

	# ✅ Updraft claro: Y negativo = hacia ARRIBA (en 2D)
	var g_strength: float = -18.0 * clamp(updraft, 0.0, 2.0) # más magnitud = sube más
	mat.gravity = Vector3(0, g_strength, 0)

	mat.direction = Vector3(0, -1, 0)
	mat.spread = 12.0

	# Nacen en círculo chico (columna compacta)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 12.0

	# Velocidad inicial moderada + damping moderado → sube, pero no se va al techo
	mat.initial_velocity_min = 16.0 * updraft
	mat.initial_velocity_max = 28.0 * updraft
	mat.damping_min = 8.0
	mat.damping_max = 12.0

	# Remolino suave para que no sea una línea recta
	mat.radial_accel_min = -1.0
	mat.radial_accel_max = 1.0
	mat.tangential_accel_min = -6.0
	mat.tangential_accel_max = 6.0
	mat.angular_velocity_min = -10.0
	mat.angular_velocity_max = 10.0

	# Tamaños
	mat.scale_min = 0.45
	mat.scale_max = 0.55

	# Curva de escala: grande al inicio, se desvanece
	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 1.10))
	sc.add_point(Vector2(0.30, 1.00))
	sc.add_point(Vector2(1.00, 0.00))
	var sc_tex := CurveTexture.new()
	sc_tex.curve = sc
	mat.scale_curve = sc_tex

	# Rampa de color con plateau de opacidad al inicio
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
	parent.add_child(ps)
	ps.emitting = true

	# Cortar la emisión según la duración total del efecto
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = max(duration, 0.05)
	parent.add_child(t)

	# Liberar cuando no queden partículas vivas
	ps.finished.connect(Callable(ps, "queue_free"), CONNECT_ONE_SHOT)

	t.timeout.connect(func():
		ps.emitting = false
	)
	t.start()


static func attach_sulfur_layer(parent: Node, pos: Vector2, duration: float = 0.9) -> void:
	if not is_instance_valid(parent):
		return

	var ps := GPUParticles2D.new()
	ps.global_position = pos

	# ✅ Emisión continua; cortamos a los `duration` segs con un Timer
	ps.one_shot = false

	# 🧪 Lifetime por partícula (fijo y corto para que no suban mucho)
	ps.lifetime = 0.75
	ps.preprocess = 0.0
	ps.local_coords = false
	ps.amount = 60
	ps.texture = SpritesHelper.get_texture_from_region(SMOKE_RECT)
	ps.visibility_rect = Rect2(Vector2(-128, -128), Vector2(256, 256))

	# Glow aditivo
	var cim := CanvasItemMaterial.new()
	cim.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ps.material = cim

	var mat := ParticleProcessMaterial.new()

	# ⚖️ Gravedad: en 2D Y positivo es hacia abajo. Estabas usando (0, -16, 0) (hacia ARRIBA).
	# Bajamos la fuerza ascendente: casi neutro o muy leve hacia arriba.
	mat.gravity = Vector3(0, -6, 0)

	# Dirección y apertura
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 60.0

	# Emisión “alfombra” baja (box plano) para pegarlo al piso
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(14, 6, 0) # ancho x alto bajos (capa fina)

	# 🚫 Velocidades más bajas + damping alto => poco desplazamiento vertical
	mat.initial_velocity_min = 6.0
	mat.initial_velocity_max = 12.0
	mat.damping_min = 14.0
	mat.damping_max = 20.0

	# Escala de partícula
	mat.scale_min = 0.35
	mat.scale_max = 0.6

	# Curva de escala (rápido a grande, luego se disipa)
	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 0.30))
	sc.add_point(Vector2(0.35, 0.90))
	sc.add_point(Vector2(1.00, 0.00))
	var sc_tex := CurveTexture.new()
	sc_tex.curve = sc
	mat.scale_curve = sc_tex

	# 🎨 Ámbar → verdoso → transparente
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
	parent.add_child(ps)

	# 🔛 Empezar a emitir ya mismo
	ps.emitting = true

	# ⏱️ Detener la emisión al cumplirse `duration`; luego liberar al morir las últimas partículas
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = max(duration, 0.05)
	parent.add_child(t)

	# Conectar antes de iniciar por seguridad
	ps.finished.connect(Callable(ps, "queue_free"), CONNECT_ONE_SHOT)

	t.timeout.connect(func():
		ps.emitting = false
		# Cuando no queden partículas vivas, se emitirá `finished` y se liberará
	)

	t.start()

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
