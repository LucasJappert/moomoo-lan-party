extends Node
class_name SoundsHelper

const FORCE_MUTED := false
static var _MUTED := false
const MAX_PLAYERS := 10
static var _players: Array[AudioStreamPlayer] = []
static var _initialized := false
static var _playing_counts: Dictionary = {} # ← sonido_path : cantidad
static var _looping_players: Array[AudioStreamPlayer] = []
static var _active_players: Array[AudioStreamPlayer] = []
static var _original_volumes := {}

static func initialize():
	if _initialized: return

	EventBus.connect(EventBus.WINDOW_FOCUSED, func(): restore_volumes())
	EventBus.connect(EventBus.WINDOW_UNFOCUSED, func(): mute_all())
	
	for i in MAX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		player.name = "SoundPlayer_%d" % i
		GameManager.audio_node.add_child(player, true)
		_players.append(player)

	_initialized = true
	print("✅ SoundsHelper initialized with %d players" % MAX_PLAYERS)

static func _internal_play(path: String, volume: float, is_looping: bool, max_simultaneous: int = 0):
	if FORCE_MUTED or _MUTED:
		return
	if not _initialized:
		push_error("⚠️ SoundsHelper not initialized.")
		return

	if not is_looping and max_simultaneous > 0:
		if _playing_counts.has(path) and _playing_counts[path] >= max_simultaneous:
			return

	var stream: AudioStream = load(path)
	if stream == null:
		push_error("🔇 Sound not found at path: " + path)
		return

	var player := _get_available_player()
	if not player:
		return

	player.stop()
	player.stream = stream
	player.volume_db = volume

	_active_players.append(player)
	_original_volumes[player] = volume

	if is_looping:
		_looping_players.append(player)
		player.finished.connect(func():
			if is_instance_valid(player):
				player.play()
		)
	else:
		_playing_counts[path] = _playing_counts.get(path, 0) + 1
		player.finished.connect(func():
			if _playing_counts.has(path):
				_playing_counts[path] = max(_playing_counts[path] - 1, 0)
			_active_players.erase(player)
			_original_volumes.erase(player)
		)
		
	player.play()

static func play_sfx(path: String, volume: float = 0.0, max_simultaneous: int = 2):
	_internal_play(path, volume, false, max_simultaneous)

static func play_looping_sfx(path: String, volume: float = 0.0):
	print("🔁 Looping sound (manual): ", path)
	_internal_play(path, volume, true)

static func stop_all_loops():
	for player in _looping_players:
		if is_instance_valid(player):
			player.stop()
		_active_players.erase(player)
		_original_volumes.erase(player)
		
	_looping_players.clear()

static func stop_loop_by_path(path: String):
	for i in range(_looping_players.size() - 1, -1, -1):
		var player = _looping_players[i]
		if is_instance_valid(player) and player.stream and player.stream.resource_path == path:
			player.stop()
			_looping_players.remove_at(i)

static func mute_all():
	_MUTED = true
	for player in _active_players:
		if is_instance_valid(player):
			player.volume_db = -80 # silencio total

static func restore_volumes():
	_MUTED = false
	for player in _active_players:
		if is_instance_valid(player) and _original_volumes.has(player):
			player.volume_db = _original_volumes[player]

# region AUXILIARIES FOR EXTERNALS
static func play_scream_hero_1(volume: float = 0.0):
	play_sfx("res://sounds/heros/scream_hero_1.wav", volume, 1)

static func _get_available_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	return _players[0]

static func play_projectile_hit(type: String, volume: float = -10.0):
	play_sfx("res://sounds/hits/" + type + ".wav", volume, 1)

static func play_critical_arrow_shot(volume: float = -15.0):
	play_sfx("res://sounds/hits/critic_arrow.wav", volume, 1) # ← Max 3 at the same time

static func play_melee_hit(volume: float = -20.0):
	var random_melee_hit := randi() % 3 + 1
	play_sfx("res://sounds/hits/melee%d.wav" % random_melee_hit, volume, 1)

static func play_critical_melee_hit(volume: float = -15.0):
	play_sfx("res://sounds/hits/critic_melee.wav", volume, 1)

static func play_lightning_spell(volume: float = -20.0):
	play_sfx("res://sounds/spells/lightning.wav", volume, 4)

static func play_electric(volume: float = -5.0):
	play_sfx("res://sounds/spells/electric.wav", volume, 4)

static func play_electric_1(volume: float = -15.0):
	play_sfx("res://sounds/spells/shock_spear.wav", volume, 4)

static func play_level_up(volume: float = -5.0):
	play_sfx("res://sounds/generals/level-up.wav", volume, 1)

static func play_beep(volume: float = -5.0):
	play_sfx("res://sounds/generals/beep.wav", volume, 1)

static func play_monster_sound(audio_id: int, max_simultaneous: int = 1, volume: float = -15.0):
	play_sfx("res://sounds/monsters/%d.wav" % audio_id, volume, max_simultaneous)

static func play_gold_sound(volume: float = -5.0):
	play_sfx("res://sounds/generals/gold.wav", volume, 2)

static func play_track1():
	SoundsHelper.play_looping_sfx("res://sounds/music/track1.wav", -10.0)

# endregion AUXILIARIES FOR EXTERNALS
