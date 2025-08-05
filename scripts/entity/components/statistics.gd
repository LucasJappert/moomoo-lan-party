class_name Statistics
extends MyInitAuxiliary

## 📊 Módulo para llevar la cuenta de estadísticas de la partida

var _time_elapsed := 0.0 # Tiempo en segundos
var _time_elapsed_int := 0
var formatted_time_elapsed := "0"
var _enemies_killed := 0
var formatted_enemies_killed := "0"
var _gold_earned := 0
var formatted_earned_gold := "0"
var _hero_name := ""
var _normal_wave_reached := 0
var _special_wave_reached := 0
var _damage_dealt := 0
var formatted_damage_dealt := "0"
var _damage_received := 0
var formatted_damage_received := "0"


var _owner: Entity

func _init(p_owner: Entity = null):
	_reset()
	super._init()
	if not p_owner: return
	_owner = p_owner
	_hero_name = _owner.extra_info.get_name_and_alias()

func _reset():
	_time_elapsed = 0.0
	_enemies_killed = 0
	_gold_earned = 0
	_hero_name = ""
	_normal_wave_reached = 0
	_special_wave_reached = 0

func _process(delta: float) -> void:
	_time_elapsed += delta
	if _time_elapsed_int != int(_time_elapsed):
		_time_elapsed_int = int(_time_elapsed)
		formatted_time_elapsed = StringHelpers.get_formatted_time(_time_elapsed_int)
		if ObjectHelpers.is_my_player(_owner): EventBus.emit_my_player_statistics_changed()

# -- Methods to update statistics --
func register_kill(count := 1) -> void:
	_enemies_killed += count
	formatted_enemies_killed = StringHelpers.format_float_compact(_enemies_killed)
	if ObjectHelpers.is_my_player(_owner): EventBus.emit_my_player_statistics_changed()

func add_gold(amount: int) -> void:
	_gold_earned += amount
	formatted_earned_gold = StringHelpers.format_float_compact(_gold_earned)
	if ObjectHelpers.is_my_player(_owner): EventBus.emit_my_player_statistics_changed()

func set_normal_wave(wave_number: int) -> void:
	_normal_wave_reached = wave_number
	if ObjectHelpers.is_my_player(_owner): EventBus.emit_my_player_statistics_changed()

func set_special_wave(wave_number: int) -> void:
	_special_wave_reached = wave_number
	if ObjectHelpers.is_my_player(_owner): EventBus.emit_my_player_statistics_changed()

func register_damage(_di: DamageInfo) -> void:
	_damage_dealt += _di.total_damage
	formatted_damage_dealt = StringHelpers.format_float_compact(_damage_dealt)
	if ObjectHelpers.is_my_player(_owner): EventBus.emit_my_player_statistics_changed()

func register_received_damage(_di: DamageInfo) -> void:
	_damage_received += _di.total_damage
	formatted_damage_received = StringHelpers.format_float_compact(_damage_received)
	if ObjectHelpers.is_my_player(_owner): EventBus.emit_my_player_statistics_changed()

static func try_register_damage(_attacker: Entity, _di: DamageInfo):
	if ObjectHelpers.is_null(_attacker): return
	_attacker.statistics.register_damage(_di)

static func try_register_received_damage(_attacker: Entity, _di: DamageInfo):
	if ObjectHelpers.is_null(_attacker): return
	_attacker.statistics.register_received_damage(_di)

# -- Safe read access --


func get_summary() -> String:
	var summary := ""
	summary += "⚡ Time: %s" % StringHelpers.get_formatted_time(int(MainScene.get_elapsed_time_in_sec()))
	summary += "\n⚡ Enemies: %d" % _enemies_killed
	summary += "\n⚡ Gold Earned: %s" % StringHelpers.format_float(_gold_earned)
	summary += "\n⚡ Hero: %s" % _hero_name
	summary += "\n⚡ Normal Wave Reached: %d" % _normal_wave_reached
	summary += "\n⚡ Special Wave Reached: %d" % _special_wave_reached
	return summary
