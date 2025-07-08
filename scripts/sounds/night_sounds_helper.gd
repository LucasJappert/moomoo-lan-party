class_name NightAmbienceHelper

static var night_sounds: Array[String] = []
static var max_simultaneous := 3
static var current_playing := 0
static var running := false

static var interval_min := 1.0
static var interval_max := 4.0

static func start(tree: SceneTree):
	if running:
		return
	_load_night_sounds()
	running = true
	_loop(tree)

static func stop():
	running = false

static func _load_night_sounds():
	night_sounds.clear()
	var dir := DirAccess.open("res://sounds/night")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav"):
				night_sounds.append("res://sounds/night/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

static func _loop(tree: SceneTree):
	if not running:
		return

	if current_playing < max_simultaneous and night_sounds.size() > 0:
		var path = night_sounds[randi() % night_sounds.size()]
		current_playing += 1
		SoundsHelper.play_sfx(path, -10.0, max_simultaneous)

		# Simula duración aproximada
		var simulated_duration := randf_range(0.5, 1.0)
		var duration_timer = tree.create_timer(simulated_duration)
		duration_timer.connect("timeout", Callable(NightAmbienceHelper, "_on_sound_finished"))

	var next_wait := randf_range(interval_min, interval_max)
	var loop_timer = tree.create_timer(next_wait)
	loop_timer.connect("timeout", func():
		_loop(tree)
	)

static func _on_sound_finished():
	current_playing = max(current_playing - 1, 0)
