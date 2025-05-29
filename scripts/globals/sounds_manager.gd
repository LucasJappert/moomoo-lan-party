extends Node
class_name SoundManager

const MAX_PLAYERS := 10
static var _players: Array[AudioStreamPlayer] = []
static var _initialized := false
static var _playing_counts: Dictionary = {} # ← sonido_path : cantidad
static var _MUTED := true

static func initialize():
	if _initialized:
		return

	for i in MAX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		player.name = "SoundPlayer_%d" % i
		GameManager.audio_node.add_child(player, true)
		_players.append(player)

	_initialized = true
	print("✅ SoundManager initialized with %d players" % MAX_PLAYERS)

static func _play_sfx(path: String, volume: float = 0.0, max_simultaneous: int = 2):
	if _MUTED: return
	if not _initialized:
		push_error("⚠️ SoundManager not initialized.")
		return

	# Evitar reproducir más de X instancias simultáneas de este sonido
	if _playing_counts.has(path) and _playing_counts[path] >= max_simultaneous:
		# print("🔇 Limit reached for sound: ", path)
		return

	var sound: AudioStream = load(path)
	if sound == null:
		push_error("🔇 Sound not found at path: " + path)
		return

	var player := _get_available_player()
	if not player:
		# push_warning("⚠️ No available AudioStreamPlayer to play the sound.")
		return
		
	player.stop()
	player.stream = sound
	player.volume_db = volume

	# Register playback
	_playing_counts[path] = _playing_counts.get(path, 0) + 1

	player.play()

	# Schedule decrement when finished
	player.finished.connect(func():
		if _playing_counts.has(path):
			_playing_counts[path] = max(_playing_counts[path] - 1, 0)
	)
	

static func _get_available_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	return _players[0]

static func play_projectile_hit(type: String, volume: float = -15.0):
	_play_sfx("res://sounds/hits/" + type + ".wav", volume, 1)

static func play_critical_arrow_shot(volume: float = -10.0):
	_play_sfx("res://sounds/hits/critic_arrow.wav", volume, 1) # ← Max 3 at the same time

static func play_melee_hit(volume: float = -15.0):
	var random_melee_hit := randi() % 3 + 1
	_play_sfx("res://sounds/hits/melee%d.wav" % random_melee_hit, volume, 1)

static func play_critical_melee_hit(volume: float = -5.0):
	_play_sfx("res://sounds/hits/critic_melee.wav", volume, 1)
