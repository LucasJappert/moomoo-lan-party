extends Node
class_name SoundsHelper

const FORCE_MUTED := true
static var _MUTED := false
const MAX_PLAYERS := 50
static var _players: Array[AudioStreamPlayer] = []
static var _initialized := false
static var _playing_counts: Dictionary = {} # ← sonido_path : cantidad
static var _looping_players: Array[AudioStreamPlayer] = []
static var _active_players: Array[AudioStreamPlayer] = []
static var _original_volumes := {}

# ✨ NUEVO: quién está reproduciendo qué
static var _player_path: Dictionary = {} # player -> path

static func initialize(audio_node: Node):
	if _initialized: return

	EventBus.connect(EventBus.WINDOW_FOCUSED, func(): restore_volumes())
	EventBus.connect(EventBus.WINDOW_UNFOCUSED, func(): mute_all())
	
	for i in MAX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		player.name = "SoundPlayer_%d" % i
		audio_node.add_child(player, true)
		_players.append(player)

	_initialized = true
	print("✅ SoundsHelper initialized with %d players" % MAX_PLAYERS)

static var _audio_cache: Dictionary = {}
static func _internal_play(path: String, volume: float, is_looping: bool, max_simultaneous: int = 1, on_finished: Callable = Callable()) -> void:
	if FORCE_MUTED or _MUTED or not _initialized:
		if not _initialized: push_error("⚠️ SoundsHelper not initialized.")
		return

	if not _can_play(path, is_looping, max_simultaneous): return

	var stream := _get_or_load_stream(path)
	if stream == null: return

	var player := _get_available_player()
	if not player: return

	_setup_player(player, stream, volume, is_looping, path)

	# Si se pasó un callback válido, lo conectamos a finished
	if on_finished.is_valid():
		player.finished.connect(on_finished, CONNECT_ONE_SHOT)

	player.play()
	
static func _can_play(path: String, is_looping: bool, max_simultaneous: int) -> bool:
	if not is_looping and max_simultaneous > 0:
		if _playing_counts.get(path, 0) >= max_simultaneous:
			return false
	return true
static func _get_or_load_stream(path: String) -> AudioStream:
	if _audio_cache.has(path):
		return _audio_cache[path]

	if not ResourceLoader.exists(path):
		push_error("❌ Sound path not found: " + path)
		return null

	var stream: AudioStream = load(path)
	if stream == null:
		push_error("🔇 Failed to load stream from path: " + path)
		return null

	_audio_cache[path] = stream
	return stream
	
static func _setup_player(player: AudioStreamPlayer, stream: AudioStream, volume: float, is_looping: bool, path: String) -> void:
	player.stop()
	player.stream = stream
	player.volume_db = volume

	_disconnect_all_finished_connections(player)

	# Si el stream soporta loop, lo seteamos (esto es opcional si ya viene así del importador)
	if stream.has_method("set_loop"):
		stream.loop = is_looping

	_active_players.append(player)
	_original_volumes[player] = volume
	_playing_counts[path] = _playing_counts.get(path, 0) + 1

	if is_looping:
		_looping_players.append(player)
		print("🎵 Looping sound: %s" % path)

		# 👇 Nada más. No conectamos `finished`.
	else:
		player.finished.connect(func():
			if _playing_counts.has(path):
				_playing_counts[path] = max(_playing_counts[path] - 1, 0)
			_active_players.erase(player)
			_original_volumes.erase(player)
		)


static func is_playing(path: String) -> bool:
	return _playing_counts.get(path, 0) > 0

static func play_sfx(path: String, volume: float = 0.0, max_simultaneous: int = 2, on_finished: Callable = Callable()):
	_internal_play(path, volume, false, max_simultaneous, on_finished)

static func play_looping_sfx(path: String, volume: float = 0.0):
	_internal_play(path, volume, true)

static func stop_all_loops():
	for player in _looping_players:
		if is_instance_valid(player):
			player.stop()
		_active_players.erase(player)
		_original_volumes.erase(player)
		
	_looping_players.clear()

static func stop_all_sfx(fade_duration: float = 0.0) -> void:
	# hacemos copia porque vamos a modificar la lista
	var to_check := _active_players.duplicate()
	for player in to_check:
		if not is_instance_valid(player):
			continue
		# ignoramos loops (se manejan aparte)
		if _looping_players.has(player):
			continue

		var path: String = _player_path.get(player, "")
		_stop_player_now(player, path, fade_duration)

static func stop_loop_by_path(path: String, fade_duration: float = 1.0):
	for i in range(_looping_players.size() - 1, -1, -1):
		var player = _looping_players[i]
		if is_instance_valid(player) and player.stream and player.stream.resource_path == path:
			var tween := player.create_tween()
			tween.tween_property(player, "volume_db", -80.0, fade_duration).set_trans(Tween.TRANS_LINEAR)

			tween.tween_callback(func():
				# Desconectar reproducción automática en loop
				if player.is_connected("finished", Callable(player, "play")):
					player.disconnect("finished", Callable(player, "play"))

				player.stop()
				_looping_players.erase(player)
				_active_players.erase(player)
				_original_volumes.erase(player)
			)

# ✅ Limpieza centralizada (sirve para finished y para stop manual)
static func _handle_player_finished(player: AudioStreamPlayer, path: String) -> void:
	if _playing_counts.has(path):
		_playing_counts[path] = max(_playing_counts[path] - 1, 0)
	_active_players.erase(player)
	_original_volumes.erase(player)
	_player_path.erase(player)

# ✨ NUEVO: detener cualquier SFX (no-loop) por path/name
static func stop_sfx_by_path(path: String, stop_all: bool = true, fade_duration: float = 0.0) -> void:
	# Recorremos copia porque vamos a modificar _active_players
	var to_check := _active_players.duplicate()
	for player in to_check:
		if not is_instance_valid(player): continue
		# Sólo SFX: ignoramos los en loop (están en _looping_players)
		if _looping_players.has(player): continue

		var p: String = _player_path.get(player, "")
		if p != path: continue

		_stop_player_now(player, path, fade_duration)
		if not stop_all:
			break

# ✨ NUEVO: detener por path (sirve tanto para loops como sfx)
static func stop_any_by_path(path: String, fade_duration: float = 0.0) -> void:
	# Primero loops
	stop_loop_by_path(path, fade_duration)
	# Luego sfx
	stop_sfx_by_path(path, true, fade_duration)

static func _stop_player_now(player: AudioStreamPlayer, path: String, fade_duration: float) -> void:
	if not is_instance_valid(player): return
	_disconnect_all_finished_connections(player)

	if fade_duration > 0.0:
		var tween := player.create_tween()
		tween.tween_property(player, "volume_db", -80.0, fade_duration).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(func():
			player.stop()
			_handle_player_finished(player, path)
		)
	else:
		player.stop()
		_handle_player_finished(player, path)

static func _on_looping_player_finished(player: AudioStreamPlayer, path: String) -> void:
	if is_instance_valid(player):
		print("🔁 Looping sound: ", path)
		player.play()

static func _disconnect_all_finished_connections(player: AudioStreamPlayer) -> void:
	for conn in player.get_signal_connection_list("finished"):
		if conn.has("target") and conn.has("method") and is_instance_valid(conn["target"]):
			player.disconnect("finished", Callable(conn["target"], conn["method"]))

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

	print("🎵 No available players")
	return null

static func play_projectile_hit(type: String, volume: float = -10.0):
	play_sfx("res://sounds/hits/" + type + ".wav", volume, 1)

static func play_critical_arrow_shot(volume: float = -15.0):
	play_sfx("res://sounds/hits/critic_arrow.wav", volume, 1) # ← Max 3 at the same time

static func play_melee_hit(volume: float = -25.0):
	var random_melee_hit := randi() % 3 + 1
	play_sfx("res://sounds/hits/melee%d.wav" % random_melee_hit, volume, 1)

static func play_critical_melee_hit(volume: float = -15.0):
	play_sfx("res://sounds/hits/critic_melee.wav", volume, 1)

static func play_lightning_spell(volume: float = -20.0):
	play_sfx("res://sounds/spells/lightning.wav", volume, 4)

static func play_electric(volume: float = -5.0):
	play_sfx("res://sounds/spells/electric.wav", volume, 3)

static func play_electric_1(volume: float = -10.0):
	play_sfx("res://sounds/spells/shock_spear.wav", volume, 4)

static func play_level_up(volume: float = -5.0):
	play_sfx("res://sounds/generals/level-up.wav", volume, 1)

static func play_beep(volume: float = -10.0):
	play_sfx("res://sounds/generals/countdown.wav", volume, 1)
	
static func play_fight(volume: float = -10.0):
	play_sfx("res://sounds/generals/fight.wav", volume, 1)

static func play_monster_sound(audio_id: int, max_simultaneous: int = 1, volume: float = -15.0):
	play_sfx("res://sounds/monsters/%d.wav" % audio_id, volume, max_simultaneous)

static func play_coins(volume: float = -5.0):
	play_sfx("res://sounds/generals/gold.wav", volume, 2)

static func play_track1(volume: float = -10.0):
	SoundsHelper.play_looping_sfx("res://sounds/music/track1.wav", volume)

static func play_random_ice_hit():
	var random_ice_hit := randi() % 4 + 1
	play_sfx("res://sounds/hits/ice/%d.wav" % random_ice_hit, -10.0, 1)

static func play_dying():
	var available_types := ["dying1", "dying2", "dying3", "dying4", "dying5"]
	var random_dying := randi() % available_types.size()
	play_sfx("res://sounds/generals/dying/%s.wav" % available_types[random_dying], -10.0, 3)

static func play_random_drink():
	var random_id := randi() % 3 + 1
	play_sfx("res://sounds/generals/drink%d.wav" % random_id, -10.0, 1)
# endregion AUXILIARIES FOR EXTERNALS
