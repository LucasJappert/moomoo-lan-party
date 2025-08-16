extends Node
class_name MusicHelper

# 🎵 Ruta base de las músicas
const MUSIC_FOLDER := "res://sounds/music/instrumental/"

# 🎶 Nombres de archivos .ogg (sin ruta completa)
const TRACK_FILES: Array[String] = [
	"dark-winds.OGG",
	"foxie-epics.OGG"
]
# 🔁 Pistas cargadas
var _playlist: Array[AudioStream] = []
var _current_track_index := 0
var _player := AudioStreamPlayer.new()
const MIN_DB: float = -30.0
const MAX_DB: float = 0

# ▶️ Estado
var _is_paused := false

func _ready() -> void:
	add_child(_player)
	set_volume_percent(0.5)
	_player.connect("finished", Callable(self, "_on_track_finished"))
	_load_playlist()
	_play_next()
	
	EventBus.connect(EventBus.WINDOW_FOCUSED, func(): resume_music())
	EventBus.connect(EventBus.WINDOW_UNFOCUSED, func(): pause_music())

func _load_playlist() -> void:
	_playlist.clear()
	for filename in TRACK_FILES:
		var path := MUSIC_FOLDER + filename
		var stream := load(path)
		if stream and stream is AudioStream:
			_playlist.append(stream)
		else:
			push_warning("Could not load music file: " + path)

func _play_next() -> void:
	if _playlist.is_empty(): return

	_player.stream = _playlist[_current_track_index]
	_player.play()
	_current_track_index = (_current_track_index + 1) % _playlist.size()

func _on_track_finished() -> void:
	if not _is_paused:
		_play_next()

var _paused_position := 0.0
# 🔇 Pausar
func pause_music() -> void:
	if _player.playing:
		_paused_position = _player.get_playback_position()
		_player.stop()
		_is_paused = true

# 🔊 Reanudar
func resume_music() -> void:
	if _is_paused:
		_player.play()
		_player.seek(_paused_position)
		_is_paused = false

func is_playing() -> bool:
	return _player.playing and not _is_paused

# Cambiar el volumen en decibeles directamente
func set_volume_db(db: float) -> void:
	_player.volume_db = clamp(db, MIN_DB, MAX_DB)

# Obtener el volumen actual en dB
func get_volume_db() -> float:
	return _player.volume_db

# Aumentar volumen en pasos
func increase_volume(step := 1.0) -> void:
	set_volume_db(_player.volume_db + step)

# Disminuir volumen en pasos
func decrease_volume(step := 1.0) -> void:
	set_volume_db(_player.volume_db - step)

# También podés trabajar con porcentaje (0 a 1) si preferís:
func set_volume_percent(percent: float) -> void:
	# Nuevo rango: de -30 dB a 0 dB (más útil)
	var db: float = lerp(MIN_DB, MAX_DB, clamp(percent, 0.0, 1.0))
	set_volume_db(db)

func get_volume_percent() -> float:
	return inverse_lerp(MIN_DB, MAX_DB, _player.volume_db)
