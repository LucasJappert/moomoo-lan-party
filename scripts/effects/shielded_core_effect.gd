extends Node2D
class_name ShieldOrbitEffect

@export var num_shields: int = 5
@export var radius: float = 16.0
@export var rotation_speed: float = 3.0
@export var rect_region: Rect2 = Rect2(96, 256, 32, 32) # magic shield

const COLOR_TINT := Color(0.4, 0.7, 1.1)

const VERTICAL_FLATTENING := 0.3 # menor = más achatado
const FADE_DURATION := 0.1

const BASE_SCALE := 0.3
const SHIELDS_BY_WAVE := 4
var shields: Array[ShieldData] = []
var rotation_offset := 0.0

class ShieldData:
	var sprite: Sprite2D
	var base_angle: float
	var direction: int
	var use_tint: bool

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

	_create_shield_group(+1, false, atlas_tex) # derecha sin tinte
	_create_shield_group(-1, true, atlas_tex) # izquierda con tinte

func _create_shield_group(direction: int, use_tint: bool, atlas_tex: Texture2D):
	for i in range(SHIELDS_BY_WAVE):
		var shield := Sprite2D.new()
		shield.texture = atlas_tex
		shield.z_as_relative = true
		add_child(shield)

		var data := ShieldData.new()
		data.sprite = shield
		data.base_angle = TAU * i / SHIELDS_BY_WAVE
		data.direction = direction
		data.use_tint = use_tint

		shields.append(data)

func _process(_delta: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	var base_color := Color(1, 1, 1)
	var pulse_speed := 20.0

	for data in shields:
		var angle := data.base_angle + time * rotation_speed * data.direction

		var x := radius * cos(angle)
		var y := radius * sin(angle) * VERTICAL_FLATTENING
		var depth := -sin(angle)

		var scale_factor := BASE_SCALE * (0.5 + 0.5 * (1.0 - depth))
		var alpha = clamp((1.0 - depth), 0.0, 1.0)

		var shield := data.sprite
		shield.position = Vector2(x, y)
		shield.scale = Vector2.ONE * scale_factor
		shield.modulate.a = alpha

		if data.use_tint:
			shield.modulate = COLOR_TINT
		else:
			shield.modulate = base_color

		shield.modulate.a = alpha # en ambos casos


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
