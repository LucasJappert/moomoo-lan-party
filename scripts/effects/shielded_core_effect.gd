extends Node2D
class_name ShieldOrbitEffect

@export var num_shields: int = 5
@export var radius: float = 16.0
@export var rotation_speed: float = 3.0
@export var rect_region: Rect2 = Rect2(96, 256, 32, 32) # magic shield

var PULSE_SPEED := 40.0 # pulse speed (higher = faster)
const COLOR_TINT := Color(0.4, 0.7, 1.1)

const VERTICAL_FLATTENING := 0.3 # menor = más achatado
const FADE_DURATION := 0.1

const BASE_SCALE := 0.3
var shields: Array[Sprite2D] = []
var rotation_offset := 0.0


static func attach_to(target_node: Node2D, duration: float = 1.0, max_stacks: int = 1) -> ShieldOrbitEffect:
	if not target_node: return null

	_try_to_remove_older_effects(target_node, max_stacks)

	var effect := ShieldOrbitEffect.new()
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
	if not target_node: return
	for child in target_node.get_children():
		if child is ShieldOrbitEffect:
			child.queue_free()

static func get_current_shields(target_node: Node) -> Array[ShieldOrbitEffect]:
	if not target_node:
		return []

	var result: Array[ShieldOrbitEffect] = []
	for child in target_node.get_children():
		if child is ShieldOrbitEffect:
			result.append(child as ShieldOrbitEffect)
	return result


func _ready():
	rotation_offset = randf() * TAU

	var atlas_tex := AtlasTexture.new()
	atlas_tex.atlas = SpritesHelper._ATLAS1
	atlas_tex.region = rect_region

	for i in range(num_shields):
		var shield := Sprite2D.new()
		shield.texture = atlas_tex
		add_child(shield)
		shields.append(shield)

func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	var base_color := Color(1, 1, 1) # o el color original del escudo si tenés uno

	for i in range(num_shields):
		var angle := (float(i) / num_shields) * TAU + time * rotation_speed + rotation_offset

		var x := radius * cos(angle)
		var y := radius * sin(angle) * VERTICAL_FLATTENING # vertical squash para sensación de profundidad

		var depth := -sin(angle) # más cerca cuando sin(angle) es negativo
		var scale_factor := BASE_SCALE * (0.5 + 0.5 * (1.0 - depth))
		var alpha: float = clamp((1.0 - depth), 0.0, 1.0)

		var shield := shields[i]
		shield.position = Vector2(x, y)
		shield.scale = Vector2.ONE * scale_factor
		shield.modulate.a = alpha

		# 💡 Alternar entre color base y tintado
		var color_t := (sin(time * PULSE_SPEED + i) + 1.0) / 2.0 # oscila entre 0 y 1
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

	for shield in shields:
		tween.parallel().tween_property(shield, "modulate:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(Callable(self, "_on_fade_complete"))

func _on_fade_complete():
	queue_free()
