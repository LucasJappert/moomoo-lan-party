class_name Statistics
extends MyInitAuxiliary

## 📊 Módulo para llevar la cuenta de estadísticas de la partida

var _time_elapsed := 0.0 # Tiempo en segundos
var _enemies_killed := 0
var _gold_earned := 0
var _hero_name := ""
var _wave_reached := 0

var _owner: Entity

func _init(p_owner: Entity):
	_reset()
	super._init()
	_owner = p_owner
	_hero_name = _owner.extra_info.get_name_and_alias()

func _reset():
	_time_elapsed = 0.0
	_enemies_killed = 0
	_gold_earned = 0
	_hero_name = ""
	_wave_reached = 0

func _process(delta: float) -> void:
	_time_elapsed += delta

# -- Methods to update statistics --
func register_kill(count := 1) -> void: _enemies_killed += count

func add_gold(amount: int) -> void: _gold_earned += amount

func set_wave(wave_number: int) -> void: _wave_reached = wave_number

# -- Safe read access --
func _get_formatted_time() -> String:
	var minutes := int(_time_elapsed / 60)
	var seconds := int(_time_elapsed) % 60
	return "%02d:%02d" % [minutes, seconds]

func get_summary() -> String:
	var summary := ""
	summary += "⏱ Time: %s\n" % _get_formatted_time()
	summary += "⚔️ Enemies: %d\n" % _enemies_killed
	summary += "💰 Gold Earned: %d\n" % _gold_earned
	summary += "⚡ Hero: %s\n" % _hero_name
	summary += "🌊 Wave Reached: %d" % _wave_reached
	return summary
