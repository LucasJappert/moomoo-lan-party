extends Node2D
class_name LineEffect

@export var duration: float = 1.0 # Tiempo que permanece visible antes de desvanecerse
@export var fade_time: float = 0.5 # Tiempo que tarda en desaparecer gradualmente

const SHADER = preload("res://shaders/zigzag_rayo.gdshader")
const RECT_REGION := Rect2(0, 864, 512, 128)
var sprite: Sprite2D

func show_between(start_pos: Vector2, end_pos: Vector2) -> void:
	sprite = SpritesHelper.get_sprite_2d(RECT_REGION)
	# Aplicar shader de rayo zigzagueante
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	sprite.material = mat

	sprite.centered = true
	add_child(sprite)

	# Posicionar el nodo principal en el origen
	position = start_pos

	var dir = end_pos - start_pos
	var angle = dir.angle()
	var length = dir.length()

	# Rotar el nodo completo (LineEffect)
	rotation = angle

	# Escalar sprite para cubrir la distancia
	sprite.scale.x = length / sprite.texture.get_width()
	sprite.scale.y = 0.4 # grosor constante

	# Colocar sprite con su centro horizontal en el origen (desplazar a la derecha la mitad del largo)
	sprite.position = Vector2(length / 2, 0)

	await get_tree().create_timer(duration).timeout
	_start_fade_out()


func _start_fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, fade_time)
	tween.tween_callback(Callable(self, "queue_free"))

# 📦 Instanciador rápido
static func spawn(parent: Node, start_pos: Vector2, end_pos: Vector2, _duration := 1.0, _fade_time := 0.5) -> void:
	var effect := LineEffect.new()
	effect.duration = _duration
	effect.fade_time = _fade_time
	parent.add_child(effect)
	effect.show_between(start_pos, end_pos)
