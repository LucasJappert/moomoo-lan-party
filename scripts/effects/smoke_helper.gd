class_name SmokeHelper

# Ajustá esta región a tu sprite de “smoke puff” en el atlas:
const SMOKE_RECT: Rect2 = Rect2(896, 256, 32, 32) # ejemplo; cambiala a la que uses

static func spawn_smoke(parent: Node, global_position: Vector2, lifetime: float) -> void:
	if not is_instance_valid(parent):
		return

	var ps := GPUParticles2D.new()
	# Colocación y orden
	ps.global_position = global_position
	# ps.z_index = 200

	# Emisión tipo “puff”
	ps.one_shot = true
	ps.lifetime = max(lifetime, 0.05)
	# ps.preprocess = ps.lifetime * 0.25 # aparece ya “iniciado” (opcional)
	ps.local_coords = false
	ps.amount = 280 # densidad del puff (subí/bajá a gusto)

	# Textura: ideal un disco/grano suave del atlas
	ps.texture = SpritesHelper.get_texture_from_region(SMOKE_RECT)

	# MUY importante si local_coords=false: ampliar visibilidad
	ps.visibility_rect = Rect2(Vector2(-160, -160), Vector2(320, 320))

	# Material de proceso
	var mat := ParticleProcessMaterial.new()
	# En Godot 4, incluso en 2D, usa Vector3:
	mat.gravity = Vector3(0, -24, 0)
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 28.0 # menos lateral, más vertical

	# Nacen más “esparcidos” en el suelo
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 10.0 # radio de dispersión inicial en píxeles

	# Velocidad/amortiguación acordes
	mat.initial_velocity_min = 12.0
	mat.initial_velocity_max = 36.0
	mat.damping_min = 10.0
	mat.damping_max = 16.0

	# Aceleraciones sutiles para dar “vida”
	mat.radial_accel_min = -5.0 # se expande un poco
	mat.radial_accel_max = 5.0
	mat.tangential_accel_min = -8.0
	mat.tangential_accel_max = 8.0
	mat.angular_velocity_min = -30.0
	mat.angular_velocity_max = 30.0

	# Tamaño base chico; lo modulamos con curva
	mat.scale_min = 0.5
	mat.scale_max = 1.0

	# Curva de escala (crece y se desvanece)
	# Curva de escala: crece, sostiene un toque, se apaga
	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 0.35))
	sc.add_point(Vector2(0.40, 1.10))
	sc.add_point(Vector2(1.00, 0.00))
	var sc_tex := CurveTexture.new()
	sc_tex.curve = sc
	mat.scale_curve = sc_tex

	# Rampa de color (gris → transparente)
	# var grad := Gradient.new()
	# # grad.colors = PackedColorArray([
	# # 	Color(0.75, 0.75, 0.75, 0.75), # gris con alpha
	# # 	Color(0.75, 0.75, 0.75, 0.0) # totalmente transparente
	# # ])
	# grad.colors = PackedColorArray([
	# 	Color(0.75, 0.75, 0.75, 0.3), # al inicio casi invisible
	# 	Color(0.75, 0.75, 0.75, 0.5), # se hace visible a mitad de vida
	# 	Color(0.75, 0.75, 0.75, 0.0) # se desvanece al final
	# ])
	# # mat.initial_color = Color(0.75, 0.75, 0.75, 0.4)  # arranque semitransparente

	# Rampa “volcánica”: brillo cálido al inicio -> gris ceniza -> transparente
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(1.0, 0.55, 0.2, 0.35), # ámbar suave, semi-transparente
		Color(0.65, 0.6, 0.55, 0.45), # ceniza tibia en medio
		Color(0.55, 0.55, 0.55, 0.0) # se disipa a transparente
	])

	var ramp := GradientTexture1D.new()
	ramp.gradient = grad
	mat.color_ramp = ramp

	ps.process_material = mat

	# Agregar y disparar
	parent.add_child(ps)
	ps.emitting = true

	# Autolimpieza al finalizar (sin lambdas)
	ps.finished.connect(Callable(ps, "queue_free"), CONNECT_ONE_SHOT)

static func _attach_sulfur_layer(parent: Node, pos: Vector2, lifetime: float = 0.9) -> void:
	if not is_instance_valid(parent):
		return

	var ps := GPUParticles2D.new()
	ps.global_position = pos
	ps.one_shot = true
	ps.lifetime = lifetime # ↑ un poco más que antes
	ps.local_coords = false
	ps.amount = 60
	ps.texture = SpritesHelper.get_texture_from_region(SMOKE_RECT)
	ps.visibility_rect = Rect2(Vector2(-128, -128), Vector2(256, 256))
	# Modo aditivo para que “brille” sobre el fondo
	var cim := CanvasItemMaterial.new()
	cim.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	ps.material = cim

	var mat := ParticleProcessMaterial.new()
	mat.gravity = Vector3(0, -16, 0)
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 60.0
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 12.0

	mat.initial_velocity_min = 10.0
	mat.initial_velocity_max = 22.0
	mat.damping_min = 8.0
	mat.damping_max = 12.0

	mat.scale_min = 0.35
	mat.scale_max = 0.6

	var sc := Curve.new()
	sc.add_point(Vector2(0.00, 0.30))
	sc.add_point(Vector2(0.35, 0.90))
	sc.add_point(Vector2(1.00, 0.00))
	var sc_tex := CurveTexture.new()
	sc_tex.curve = sc
	mat.scale_curve = sc_tex

	# Ámbar → verdoso → transparente (glow místico)
	var g := Gradient.new()
	g.colors = PackedColorArray([
		Color(1.00, 0.65, 0.25, 0.25), # ámbar suave al nacer
		Color(0.70, 0.95, 0.25, 0.35), # verde-azufre a mitad
		Color(0.60, 0.90, 0.20, 0.00) # se apaga
	])
	var gt := GradientTexture1D.new()
	gt.gradient = g
	mat.color_ramp = gt

	ps.process_material = mat
	parent.add_child(ps)
	ps.emitting = true
	ps.finished.connect(Callable(ps, "queue_free"), CONNECT_ONE_SHOT)
