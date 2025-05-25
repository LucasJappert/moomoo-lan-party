class_name SoundManager

extends Node

const MAX_PLAYERS := 10
static var _players: Array[AudioStreamPlayer] = []
static var _initialized := false
static var _root: Node = null

static func initialize(root_node: Node):
	if _initialized:
		return

	_root = root_node
	for i in MAX_PLAYERS:
		var player := AudioStreamPlayer.new()
		_root.add_child(player)
		_players.append(player)
	_initialized = true

static func _play_sfx(path: String, volume: float = 0.0):
	if not _initialized:
		push_warning("SoundManager not initialized. Call SoundManager.init(get_tree().get_root()) first.")
		return

	var sound: AudioStream = load(path)
	if sound == null:
		push_warning("🔇 Sound not found: " + path)
		return

	var player := _get_available_player()
	if player:
		player.stream = sound
		player.volume_db = volume
		player.play()

static func _get_available_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	return _players[0]

static func play_arrow_impact():
	_play_sfx("res://sounds/hits/normal_arrow.wav")
