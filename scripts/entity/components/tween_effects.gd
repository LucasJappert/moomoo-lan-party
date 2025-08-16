class_name TweenEffects

# extends MyInitAuxiliary

const TYPES = {
	IDLE = "idle"
}

const IDLE_DURATION := 0.5
var tweens := {}
var _owner: Entity
var _spawn_tween: Tween = null

func _init(p_owner: Entity = null):
	# super._init()
	_owner = p_owner
	EventBus.connect_to_paused(func(_paused: bool, _show_menu: bool): _on_paused(_paused))

func start_idle_effect():
	if tweens.has(TYPES.IDLE):
		tweens[TYPES.IDLE].play()
		return

	var sprite := _owner.body_sprite
	var tween := _owner.create_tween()
	tween.set_loops()

	var base_scale := sprite.scale
	var sprite_height := _owner.sprite_height
	var original_y := sprite.position.y

	# Target scale
	var scale_x_target := base_scale.x * 1.03
	var scale_y_target := base_scale.y * 0.97

	# Vertical correction: how much the sprite shrinks when scaling in Y
	var delta_y := sprite_height * (1.0 - scale_y_target / base_scale.y) / 2.0

	# Random delay to desynchronize between entities
	var variation := IDLE_DURATION * randf_range(-0.1, 0.1)
	var FINAL_DURATION := IDLE_DURATION + variation

	# Breathing: scale + Y correction
	tween.tween_property(sprite, "scale", Vector2(scale_x_target, scale_y_target), FINAL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "position:y", original_y + delta_y, FINAL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(sprite, "scale", base_scale, FINAL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(sprite, "position:y", original_y, FINAL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


	tweens[TYPES.IDLE] = tween

func apply_spawn_effect() -> void:
	const SPAWN_DURATION := 0.5

	if is_instance_valid(_spawn_tween):
		_spawn_tween.kill()
		_spawn_tween = null

	var tween := _owner.create_tween()
	_spawn_tween = tween

	_owner.modulate = Color(0, 0, 0, 0)
	_owner.scale = Vector2.ZERO

	tween.tween_property(_owner, "modulate", Color.WHITE, SPAWN_DURATION)
	tween.parallel().tween_property(_owner, "scale", Vector2.ONE, SPAWN_DURATION)

	tween.finished.connect(func() -> void:
		if tween == _spawn_tween:
			_spawn_tween = null
			_owner.set_is_spawning(false)
			# callback seguro acá
	, CONNECT_ONE_SHOT)

func pause_effect(name: String):
	if tweens.has(name):
		var t = tweens[name]
		if is_instance_valid(t) and t.is_inside_tree():
			t.pause()

func stop_effect(name: String):
	if tweens.has(name):
		var t = tweens[name]
		if is_instance_valid(t):
			t.kill()
		tweens.erase(name)

func stop_all_effects():
	for t in tweens.values():
		t.kill()
	tweens.clear()

func _on_paused(paused: bool):
	for t in (tweens.values() as Array[Tween]):
		if is_instance_valid(t) and t.is_running() and t.is_valid():
			if paused: t.pause()
			else: t.play()

const SPAWN_REGION: Rect2 = Rect2(640, 256, 64, 64)
static func apply_spawn_spin_effect(parent: Node, position: Vector2, lifetime: float = 2) -> void:
	return apply_spin_flat_3d(parent, position, SpritesHelper.get_sprite_2d(SPAWN_REGION), lifetime, 0.5, 1)

const REFLECT_REGION: Rect2 = Rect2(704, 256, 64, 64)
static func apply_reflect_spin_effect(parent: Node, position: Vector2, lifetime: float) -> void:
	var sprite := SpritesHelper.get_sprite_2d(REFLECT_REGION)
	apply_spin_flat_3d(parent, position, sprite, lifetime)

static func apply_spin_flat_3d(parent: Node, position: Vector2, sprite: Sprite2D,
	lifetime: float = 1, fade_in: float = 0.25, fade_out: float = 0.25
) -> void:
	if not is_instance_valid(parent):
		return

	# Contenedor que aplasta SIEMPRE en el eje de pantalla (Y = 0.5)
	var flat := Node2D.new()
	flat.global_position = position
	flat.scale = Vector2(1.0, 0.5) # alto constante a la mitad
	parent.add_child(flat)

	# Nodo que solo rota (dentro del aplanado)
	var rot := Node2D.new()
	flat.add_child(rot)

	# Sprite desde tu atlas
	sprite.modulate = Color(0, 0, 0, 0) # fade-in
	sprite.scale = Vector2.ZERO
	rot.add_child(sprite)

	# Parámetros internos (ajustá el "feel" acá)
	var hold: float = max(lifetime - (fade_in + fade_out), 0.0)
	var total: float = fade_in + hold + fade_out
	var ROT_DPS := 360.0 # grados por segundo

	# Fade-in -> hold -> fade-out (todo en un tween)
	var t := flat.create_tween()
	t.tween_property(sprite, "modulate", Color(1, 1, 1, 1), max(fade_in, 0.01))
	t.parallel().tween_property(sprite, "scale", Vector2.ONE, fade_in)
	if hold > 0.0: t.tween_interval(hold)
	t.tween_property(sprite, "modulate", Color(0, 0, 0, 0), max(fade_out, 0.01))
	t.parallel().tween_property(sprite, "scale", Vector2.ZERO, fade_out)

	# Rotación continua durante toda la vida
	var r := flat.create_tween()
	r.set_trans(Tween.TRANS_LINEAR)
	r.tween_property(rot, "rotation_degrees", ROT_DPS * total, total).as_relative()

	# Limpieza al terminar (sin lambdas)
	t.finished.connect(Callable(flat, "queue_free"), CONNECT_ONE_SHOT)

static func apply_scale_looped_effect(parent: Node, sprite: Sprite2D, from: Vector2, to: Vector2, lifetime: float = 1, speed: float = 1) -> void:
	if not is_instance_valid(parent):
		return

	parent.add_child(sprite)

	# Guardamos escala original y seteamos punto de partida del pulso.
	var original_scale: Vector2 = sprite.scale
	sprite.scale = from

	# Duraciones: speed = pulsos por segundo -> periodo = 1/speed.
	var safe_speed: float = max(speed, 0.0001)
	var half_period: float = 0.5 / safe_speed
	var life: float = max(lifetime, 0.0001)

	# Tween de pulso (loop infinito): from -> to -> from ...
	var pulse := sprite.create_tween()
	pulse.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse.set_loops(0) # 0 = infinito en Godot 4
	pulse.tween_property(sprite, "scale", to, half_period)
	pulse.tween_property(sprite, "scale", from, half_period)

	# "Temporizador" de vida basado en tween: al terminar, matamos el loop y restauramos escala.
	var life_tween := sprite.create_tween()
	life_tween.tween_interval(life)
	life_tween.finished.connect(Callable(pulse, "kill"), CONNECT_ONE_SHOT)
	life_tween.finished.connect(Callable(sprite, "set").bind("scale", original_scale), CONNECT_ONE_SHOT)
