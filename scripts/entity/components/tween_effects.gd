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

func start_idle_effect():
	if tweens.has(TYPES.IDLE):
		tweens[TYPES.IDLE].play()
		return

	var sprite := _owner.body_sprite
	var t := _owner.create_tween()
	t.set_loops()

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
	t.tween_property(sprite, "scale", Vector2(scale_x_target, scale_y_target), FINAL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(sprite, "position:y", original_y + delta_y, FINAL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	t.tween_property(sprite, "scale", base_scale, FINAL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(sprite, "position:y", original_y, FINAL_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


	tweens[TYPES.IDLE] = t


func pause_effect(name: String):
	if tweens.has(name):
		tweens[name].pause()

func stop_effect(name: String):
	if tweens.has(name):
		tweens[name].kill()
		tweens.erase(name)

func stop_all_effects():
	for t in tweens.values():
		t.kill()
	tweens.clear()
