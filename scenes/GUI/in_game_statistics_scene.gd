extends PanelContainer
class_name InGameStatistics

@onready var _label: Label = %Label

const TITLE_WIDTH := 20
const VALUE_WIDTH := 14

func _ready():
	_label.text = ""
	EventBus.connect_to_my_player_statistics_changed(func(): _update_text())

func _update_text() -> void:
	if not GameManager.MY_PLAYER:
		return

	var is_english := LanguageManager.is_english()

	var result := ""
	result += "- " + ("FPS:" if is_english else "FPS:") + " %d\n" % Performance.get_monitor(Performance.TIME_FPS)
	result += "- " + ("TIME ELAPSED: " if is_english else "TIEMPO TRANSCURRIDO: ") + GameManager.MY_PLAYER.statistics.formatted_time_elapsed + "\n"
	result += "- " + ("NORMAL WAVE REACHED: " if is_english else "OLEADA NORMAL ALCANZADA: ") + "%d %s %d\n" % [
		EnemiesWavesController.current_wave,
		("of" if is_english else "de"),
		EnemiesWavesController.WAVES_INFO.size()
	]
	result += "- " + ("SPECIAL WAVE REACHED: " if is_english else "OLEADA ESPECIAL ALCANZADA: ") + "%d\n" % EnemiesWavesController.special_wave
	result += "- " + ("UNITS KILLED: " if is_english else "UNIDADES ELIMINADAS: ") + GameManager.MY_PLAYER.statistics.formatted_enemies_killed + "\n"
	result += "- " + ("DAMAGE DEALT: " if is_english else "DAÑO INFLIGIDO: ") + GameManager.MY_PLAYER.statistics.formatted_damage_dealt + "\n"
	result += "- " + ("DAMAGE RECEIVED: " if is_english else "DAÑO RECIBIDO: ") + GameManager.MY_PLAYER.statistics.formatted_damage_received + "\n"
	result += "- " + ("GOLD EARNED: " if is_english else "ORO GANADO: ") + GameManager.MY_PLAYER.statistics.formatted_earned_gold + "\n"

	_label.text = result
