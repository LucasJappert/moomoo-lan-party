extends Node2D
class_name StunEffect

@export var radius: float = 8.0
@export var num_stars: int = 3
@export var rotation_speed: float = 2


const BASE_STAR_SCALE := 0.4 # Adjust this value to your liking
const STAR_REGION := Rect2(64, 256, 32, 32)

var stars: Array[Sprite2D] = []
var rotation_offset := 0.0

static func attach_to(target_node: Node2D, duration: float = 1.0) -> StunEffect:
	if not target_node: return
	var effect := StunEffect.new()
	target_node.add_child(effect)
	effect.position = Vector2(0, -64) # adjust according to sprite
	effect._start_timer(duration)
	return effect

static func remove_all_from(target_node: Node) -> void:
	if not target_node: return
	for child in target_node.get_children():
		if child is StunEffect:
			child.queue_free()

func _ready():
	rotation_offset = randf() * TAU # Random angular offset
	var atlas_tex := AtlasTexture.new()
	atlas_tex.atlas = SpritesHelper._ATLAS1
	atlas_tex.region = STAR_REGION

	for i in range(num_stars):
		var sprite := Sprite2D.new()
		sprite.texture = atlas_tex
		sprite.scale = Vector2.ZERO
		add_child(sprite)
		stars.append(sprite)

func _process(_delta):
	var time := Time.get_ticks_msec() / 1000.0
	for i in range(num_stars):
		# Reverse the direction of rotation
		var angle := (float(i) / num_stars) * TAU - time * rotation_speed + rotation_offset
		
		var x := radius * cos(angle)
		var y := radius * -sin(angle) * 0.5 # Reverse Y axis for depth effect

		var _scale_factor := BASE_STAR_SCALE * (0.5 + 0.5 * (y / radius))
		var sprite := stars[i]
		sprite.position = Vector2(x, y)
		sprite.scale = Vector2.ONE * _scale_factor
		# star.modulate = Color(1, 1, 1, clamp(_scale_factor / BASE_STAR_SCALE, 0.0, 1.0))
		sprite.modulate = Color(1, 1, 1, 1)

func _start_timer(duration: float) -> void:
	var timer := Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout():
	queue_free()
