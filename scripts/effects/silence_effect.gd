extends Node2D
class_name SilenceEffect

@export var radius: float = 8.0
@export var num_of_sprites: int = 2
@export var rotation_speed: float = 2


const BASE_SPRITE_SCALE := 0.4 # Adjust this value to your liking
const STAR_REGION := Rect2(288, 256, 32, 32)

var sprites: Array[Sprite2D] = []
var rotation_offset := 0.0

static func attach_to(target_node: Node2D, duration: float = 1.0) -> SilenceEffect:
	if not target_node: return
	var effect := SilenceEffect.new()
	target_node.add_child(effect)
	effect.position = Vector2(0, -64) # adjust according to sprite
	effect._start_timer(duration)
	return effect

static func remove_all_from(target_node: Node) -> void:
	if not target_node: return
	for child in target_node.get_children():
		if child is SilenceEffect:
			child.queue_free()

func _ready():
	rotation_offset = randf() * TAU # Random angular offset
	var atlas_tex := AtlasTexture.new()
	atlas_tex.atlas = SpritesHelper._ATLAS1
	atlas_tex.region = STAR_REGION

	for i in range(num_of_sprites):
		var star := Sprite2D.new()
		star.texture = atlas_tex
		add_child(star)
		sprites.append(star)

func _process(_delta):
	var time := Time.get_ticks_msec() / 1000.0
	for i in range(num_of_sprites):
		# Reverse the direction of rotation
		var angle := (float(i) / num_of_sprites) * TAU - time * rotation_speed + rotation_offset
		
		var x := radius * cos(angle)
		var y := radius * -sin(angle) * 0.5 # Reverse Y axis for depth effect

		var _scale_factor := BASE_SPRITE_SCALE * (0.5 + 0.5 * (y / radius))
		var star := sprites[i]
		star.position = Vector2(x, y)
		star.scale = Vector2.ONE * _scale_factor
		# star.modulate = Color(1, 1, 1, clamp(_scale_factor / BASE_SPRITE_SCALE, 0.0, 1.0))
		star.modulate = Color(1, 1, 1, 1)

func _start_timer(duration: float) -> void:
	var timer := Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout():
	queue_free()
