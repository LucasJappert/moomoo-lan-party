class_name MonsterSoundsHelper

const MONSTER_SOUNDS = [1, 2]

var latest_sound_timer: float
var next_sound_interval: float = 0.0
const MIN_INTERVAL: float = 5.0
const MAX_INTERVAL: float = 25.0

func _init():
	_reset_next_interval()

func try_to_play_boss_sound(_enemy: Enemy, _delta: float) -> void:
	if MainScene.PAUSED: return
	if _enemy.boss_level == 0: return

	latest_sound_timer += _delta
	if latest_sound_timer < next_sound_interval: return

	latest_sound_timer = 0.0

	var random_id = MONSTER_SOUNDS[randi() % MONSTER_SOUNDS.size()]
	SoundsHelper.play_monster_sound(random_id)

func _reset_next_interval():
	next_sound_interval = randf_range(MIN_INTERVAL, MAX_INTERVAL)
