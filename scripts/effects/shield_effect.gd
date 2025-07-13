extends Node2D
class_name ShieldEffect

@export var rect_region: Rect2 = Rect2(192, 256, 64, 64) # región del atlas para escudo

const COLOR_TINT := Color(0.4, 0.7, 1.1)
const PULSE_SPEED := 10.0
const BASE_SCALE := 0.2
const FADE_DURATION := 0.1
const VERTICAL_FLATTENING := 0.3
const WAVE_AMPLITUDE := 8.0
const WAVE_SPEED := 2.0

# Configuración de cada anillo
const RINGS := [
	{"num_shields": 2, "radius": 10.0, "rotation_speed": 2.0, "y_offset": - 50.0},
	{"num_shields": 5, "radius": 28.0, "rotation_speed": 2.5, "y_offset": - 30.0},
	{"num_shields": 3, "radius": 18.0, "rotation_speed": - 1.5, "y_offset": - 10.0},
]


var all_shields: Array[Sprite2D] = []
var ring_data: Array[Dictionary] = []


static func attach_to(target_node: Node2D, duration: float = 1.0, max_stacks: int = 1) -> ShieldEffect:
	if not target_node:
		return null

	_try_to_remove_older_effects(target_node, max_stacks)

	var effect := ShieldEffect.new()
	target_node.add_child(effect)
	effect.position = Vector2.ZERO
	effect._start_timer(duration)

	return effect


static func _try_to_remove_older_effects(target_node: Node, max_stacks: int) -> void:
	var current_effects := get_current_shields(target_node)
	if current_effects.size() >= max_stacks:
		current_effects.sort_custom(func(a, b): return a.get_instance_id() < b.get_instance_id())
		var to_remove := current_effects.size() - max_stacks + 1
		for i in range(to_remove):
			current_effects[i].queue_free()


static func remove_all_from(target_node: Node) -> void:
	if not target_node:
		return
	for child in target_node.get_children():
		if child is ShieldEffect:
			child.queue_free()


static func get_current_shields(target_node: Node) -> Array[ShieldEffect]:
	if not target_node:
		return []

	var result: Array[ShieldEffect] = []
	for child in target_node.get_children():
		if child is ShieldEffect:
			result.append(child as ShieldEffect)
	return result


func _ready():
	var atlas_tex := AtlasTexture.new()
	atlas_tex.atlas = SpritesHelper._ATLAS1
	atlas_tex.region = rect_region

	for ring in RINGS:
		var shields: Array[Sprite2D] = []
		var rotation_offset := randf() * TAU

		for i in range(ring.num_shields):
			var shield := Sprite2D.new()
			shield.texture = atlas_tex
			shield.centered = true
			add_child(shield)
			all_shields.append(shield)
			shields.append(shield)

			ring_data.append({
				"shields": shields,
				"num_shields": ring.num_shields,
				"radius": ring.radius,
				"rotation_speed": ring.rotation_speed,
				"rotation_offset": rotation_offset,
				"y_offset": ring.y_offset
			})


func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	var base_color := Color(1, 1, 1)

	for ring in ring_data:
		var shields: Array[Sprite2D] = ring["shields"]
		var num_shields: int = ring["num_shields"]
		var radius: float = ring["radius"]
		var speed: float = ring["rotation_speed"]
		var offset: float = ring["rotation_offset"]


		for i in range(num_shields):
			var angle := (float(i) / num_shields) * TAU + time * speed + offset
			var x := radius * cos(angle)
			var y := radius * sin(angle) * VERTICAL_FLATTENING
			y += sin(time * WAVE_SPEED + i) * WAVE_AMPLITUDE
			y += ring["y_offset"]
				

			var depth := -sin(angle)
			var scale_factor := BASE_SCALE * (0.5 + 0.5 * (1.0 - depth))
			var alpha = clamp((1.0 - depth), 0.0, 1.0)

			var shield := shields[i]
			shield.position = Vector2(x, y)
			shield.scale = Vector2.ONE * scale_factor

			var color_t := (sin(time * PULSE_SPEED + i) + 1.0) / 2.0
			var tint := base_color.lerp(COLOR_TINT, color_t)
			tint.a = alpha
			shield.modulate = tint


func _start_timer(duration: float) -> void:
	var timer := Timer.new()
	timer.wait_time = duration - FADE_DURATION
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(_start_fade_out)
	add_child(timer)


func _start_fade_out():
	var tween := create_tween()
	for shield in all_shields:
		tween.parallel().tween_property(shield, "modulate:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_on_fade_complete"))


func _on_fade_complete():
	queue_free()
