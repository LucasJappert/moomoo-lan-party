extends Node
class_name MyCustomTween

signal tween_completed

# Constantes de transición y easing
const TRANS_LINEAR := 0
const TRANS_SINE := 1
const EASE_IN := 0
const EASE_OUT := 1
const EASE_IN_OUT := 2

# Builder para una animación encadenable
class TweenAction:
	var node: Node
	var property: String
	var from: Variant
	var to: Variant
	var duration: float
	var transition := TRANS_LINEAR
	var _ease := EASE_IN_OUT
	var delay := 0.0

	func set_trans(trans):
		transition = trans
		return self

	func set_ease(e):
		_ease = e
		return self

	func set_delay(d):
		delay = d
		return self

	func interpolate(t: float) -> Variant:
		t = apply_ease(t, _ease)
		match transition:
			TRANS_SINE:
				t = -0.5 * (cos(PI * t) - 1.0)

		if typeof(from) in [TYPE_INT, TYPE_FLOAT] and typeof(to) in [TYPE_INT, TYPE_FLOAT]:
			return lerp(float(from), float(to), t)
		elif typeof(from) == TYPE_VECTOR2:
			return from.lerp(to, t)
		elif typeof(from) == TYPE_VECTOR3:
			return from.lerp(to, t)
		elif typeof(from) == TYPE_COLOR:
			return from.lerp(to, t)
		elif typeof(from) == TYPE_QUATERNION:
			return from.slerp(to, t)
		else:
			push_warning("No se puede interpolar tipo: %s" % typeof(from))
			return from


	func apply_ease(t: float, ease_type: int) -> float:
		match ease_type:
			EASE_IN:
				return t * t
			EASE_OUT:
				return t * (2 - t)
			EASE_IN_OUT:
				return 2 * t * t if t < 0.5 else -1 + (4 - 2 * t) * t
			_:
				return t

# Interna
var _actions: Array[TweenAction] = []
var _start_time: int = 0
var _is_active := false
var _parallel_mode := false
var _parent_node: Node

func _init(node: Node):
	_parent_node = node
	_parent_node.add_child(self)

func _process(_delta):
	if not _is_active:
		return

	var elapsed := Time.get_ticks_msec() - _start_time
	var all_finished := true

	for action in _actions:
		if elapsed < int(action.delay * 1000):
			all_finished = false
			continue

		var relative_time := float(elapsed - int(action.delay * 1000)) / (action.duration * 1000)
		relative_time = clamp(relative_time, 0.0, 1.0)
		var value = action.interpolate(relative_time)
		_apply_value(action.node, action.property, value)
		if relative_time < 1.0:
			all_finished = false

	if all_finished:
		_is_active = false
		emit_signal("tween_completed")

# API estilo Tween
func tween_property(node: Node, property: String, to: Variant, duration: float, transition := TRANS_LINEAR, p_ease := EASE_IN_OUT) -> TweenAction:
	var from = _get_initial_value(node, property)
	var action := TweenAction.new()
	action.node = node
	action.property = property
	action.from = from
	action.to = to
	action.duration = duration
	action.transition = transition
	action._ease = p_ease
	_actions.append(action)
	return action

func parallel():
	_parallel_mode = true
	return self

func start():
	_start_time = Time.get_ticks_msec()
	_is_active = true

func _get_initial_value(node: Node, property: String) -> Variant:
	if not property.contains(":"): return node.get(property)

	var parts = property.split(":")
	var base_prop = parts[0]
	var sub_prop = parts[1]

	var base_value = node.get(base_prop)
	match sub_prop:
		"x": return base_value.x
		"y": return base_value.y
		"z": return base_value.z
		"r": return base_value.r
		"g": return base_value.g
		"b": return base_value.b
		"a": return base_value.a
		_:
			push_error("Propiedad desconocida: %s" % property)
			return null


func _apply_value(node: Node, property: String, value: Variant) -> void:
	if not property.contains(":"):
		node.set(property, value)
		return

	var parts = property.split(":")
	var base_prop = parts[0]
	var sub_prop = parts[1]

	var base_value = node.get(base_prop)

	match sub_prop:
		"x": base_value.x = value
		"y": base_value.y = value
		"z": base_value.z = value
		"r": base_value.r = value
		"g": base_value.g = value
		"b": base_value.b = value
		"a": base_value.a = value
		_:
			push_error("Propiedad desconocida al aplicar: %s" % property)
			return

	node.set(base_prop, base_value)
