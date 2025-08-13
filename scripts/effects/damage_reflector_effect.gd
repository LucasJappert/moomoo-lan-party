extends Node
class_name DamageReflectorEffect
const NAME := "DamageReflectorEffect"

const ATLAS_LINE_REGION := Rect2(272, 263, 16, 2) # Línea blanca finita

static func attach_to(target: Node, duration: float = -1.0) -> Node2D:
	if target.has_node(NAME):
		target.get_node(NAME).queue_free()

	var wrapper := Node2D.new()
	wrapper.name = NAME
	wrapper.position = Vector2.ZERO
	target.add_child(wrapper)

	# En lugar de lambda, conecta directo al método:
	target.tree_exited.connect(wrapper.queue_free)

	# Crear updater
	var updater := DamageReflectorUpdater.new()
	updater.init(duration, wrapper)
	wrapper.add_child(updater)

	return wrapper

static func remove_from(target: Node) -> void:
	for node in target.get_children():
		if node.name == NAME: node.queue_free()

# --- Clase interna ---
class DamageReflectorUpdater:
	extends Node2D

	var time_left := -1.0
	var wrapper_node: Node = null
	var time_accumulator := 0.0

	func init(_duration: float, _wrapper_node: Node):
		time_left = _duration
		wrapper_node = _wrapper_node
		set_process(true)

	func _process(delta):
		# Desactivar tras duración
		if time_left > 0.0:
			time_left -= delta
			if time_left <= 0.0:
				if wrapper_node: wrapper_node.queue_free()
				return

		# Emitir líneas blancas
		time_accumulator += delta
		if time_accumulator >= 0.06:
			time_accumulator = 0.0
			for i in range(2): _emit_line_burst()

	func _emit_line_burst():
		var line = Sprite2D.new()
		line.texture = SpritesHelper.get_texture_from_region(ATLAS_LINE_REGION)
		line.centered = false
		line.position = Vector2.ZERO
		line.rotation = randf_range(0, TAU)
		line.modulate = Color(randf_range(0.5, 1.0), randf_range(0.5, 0.8), randf_range(0.8, 1.0), 1.0)
		line.scale.x = 0
		add_child(line)

		var dir = Vector2.RIGHT.rotated(line.rotation)
		var final_offset = dir * 6
		# var final_scale_y = randf_range(1.5, 2.5)

		const DURATION := 0.4
		var tween := line.create_tween()
		tween.tween_property(line, "position", final_offset, DURATION)
		tween.parallel().tween_property(line, "scale:x", 2, DURATION)
		tween.parallel().tween_property(line, "modulate:a", 1, DURATION)
		tween.tween_callback(line.queue_free)
