class_name AmbientSoundsHelper

const _VOLUME := -10
var active_fire_sounds := 0
const FIRE_PATH := "res://sounds/generals/fire.wav"

func _init() -> void:
	pass

func update_fire_sound() -> void:
	for entity in GameManager.get_entities():
		if not is_instance_valid(entity): continue
		for skill in entity._active_skills:
			if skill.has_fire(): return _try_play_fire()
		
	_stop_fire()

func _try_play_fire() -> void:
	if SoundsHelper.is_playing(FIRE_PATH): return

	SoundsHelper.play_looping_sfx(FIRE_PATH, _VOLUME)

func _stop_fire() -> void:
	SoundsHelper.stop_loop_by_path(FIRE_PATH)
