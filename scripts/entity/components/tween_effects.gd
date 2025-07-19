class_name TweenEffects

extends MyInitAuxiliary

const TYPES = {
	IDLE = "idle"
}

const IDLE_DURATION := 0.5
var tweens := {}
var _owner: Entity

func _init(p_owner: Entity):
	super._init()
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

func apply_spawn_effect():
	const SPAWN_DURATION := 0.5
	var tween := _owner.create_tween()
	_owner.modulate.a = 0
	_owner.scale = Vector2.ZERO
	_owner.modulate = Color(0, 0, 0, 0)

	tween.tween_property(_owner, "modulate", Color(1, 1, 1, 1), SPAWN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_owner, "scale", Vector2.ONE, SPAWN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): tween.kill())

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
