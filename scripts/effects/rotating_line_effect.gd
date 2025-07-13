extends Node2D
class_name RotatingRingEffect

const TEXT_REGION := Rect2(160, 288, 32, 32)
const LINE_SCALE_BASE := Vector2(1, 0.7)
const ORBIT_RADIUS := 32.0
const ROTATION_SPEED := 2 * PI # radianes por segundo
const START_Z_INDEX := 50
const FADE_TIME := 0.4

var _ORBIT_SPEED_MIN := 0.5
var _ORBIT_SPEED_MAX := 1
var _orbit_speed := randf_range(_ORBIT_SPEED_MIN, _ORBIT_SPEED_MAX)
var orbit_flatness := 0.1 # 0 = línea recta, 1 = círculo
var orbit_tilt_degrees: float = 0.0 # 0° = horizontal, 45° = diagonal, etc.
var _mesh_instance: MeshInstance2D
var _angle := 0.0
var _direction := 1.0 # +1 para horario, -1 para antihorario
var _looping := true

static func play_loop(
	target: Node2D,
	tilt_degrees: float = 0.0,
	local_offset: Vector2 = Vector2.ZERO
) -> RotatingRingEffect:
	var ring_effect := RotatingRingEffect.new()
	ring_effect.orbit_tilt_degrees = tilt_degrees
	ring_effect.position = local_offset
	target.add_child(ring_effect)
	ring_effect._start_loop()
	return ring_effect

func _start_loop() -> void:
	rotation_degrees = orbit_tilt_degrees
	_direction = 1.0 if randf() < 0.5 else -1.0
	_angle = randf_range(0.0, TAU)
	var mesh := QuadMesh.new()
	mesh.size = TEXT_REGION.size
	mesh.subdivide_width = 16 # Solo esto es válido

	_mesh_instance = MeshInstance2D.new()
	_mesh_instance.mesh = mesh
	var image = SpritesHelper._ATLAS1.get_image()
	var sub_image = image.get_region(TEXT_REGION)
	var tex := ImageTexture.create_from_image(sub_image)
	_mesh_instance.texture = tex
	_mesh_instance.scale = LINE_SCALE_BASE
	_mesh_instance.z_index = START_Z_INDEX

	var shader := load("res://shaders/curved_sprite.gdshader")
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	_mesh_instance.material = shader_material

	add_child(_mesh_instance)

	var t := create_tween()
	t.tween_property(_mesh_instance, "modulate:a", 1.0, FADE_TIME)
	set_process(true)

func _process(delta: float) -> void:
	if not _looping:
		return

	# 🔄 Control dinámico de velocidad orbital
	var sin_angle := sin(_angle)
	var speed_factor := pow(abs(sin_angle), 0.5) # más aceleración al frente y atrás
	var min_speed := 0.3
	var max_speed := 1.0
	var dynamic_speed = lerp(min_speed, max_speed, speed_factor)

	# 🧭 Actualizar ángulo con velocidad variable
	_angle = fmod(_angle + ROTATION_SPEED * dynamic_speed * delta * _direction * _orbit_speed, TAU)

	# 📍 Posición base
	var x := cos(_angle) * ORBIT_RADIUS
	var y := sin(_angle) * ORBIT_RADIUS * orbit_flatness
	_mesh_instance.position = Vector2(x, y)

	# ↔️ Escala X dinámica (achatamiento en extremos)
	var stretch = 1.0 - abs(cos(_angle))
	var min_scale := 0.0
	var max_scale := 1.0
	var dynamic_scale_x = lerp(min_scale, max_scale, stretch)
	_mesh_instance.scale.x = LINE_SCALE_BASE.x * dynamic_scale_x

	# 🌫️ Opacidad (se desvanece atrás)
	var alpha = clamp((sin_angle + 1.0) / 2.0, 0.0, 1.0)
	_mesh_instance.modulate.a = alpha

	# 🌀 Curvatura (hacia arriba al frente, hacia abajo atrás)
	var curve_strength = pow(abs(sin_angle), 1.2) * 0.01 * sign(sin_angle)
	_mesh_instance.material.set_shader_parameter("curve_amount", curve_strength)


func stop_loop():
	_looping = false
	set_process(false)

	if is_instance_valid(_mesh_instance):
		var t := create_tween()
		t.tween_property(_mesh_instance, "modulate:a", 0.0, FADE_TIME)
		t.tween_callback(Callable(self, "queue_free"))
	else:
		queue_free()
