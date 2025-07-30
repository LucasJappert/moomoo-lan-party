extends PanelContainer
class_name InGameStatistics

@onready var _label: Label = %Label

const TITLE_WIDTH := 20
const VALUE_WIDTH := 14

func _ready():
	_label.text = ""
	EventBus.connect_to_my_player_statistics_changed(func(): _update_text())

func _update_text() -> void:
	if not GameManager.MY_PLAYER: return

	var result := ""
	result += "- TIME ELAPSED: " + GameManager.MY_PLAYER.statistics.formatted_time_elapsed + "\n"
	result += "- UNITS KILLED: " + GameManager.MY_PLAYER.statistics.formatted_enemies_killed + "\n"
	result += "- DAMAGE DEALT: " + GameManager.MY_PLAYER.statistics.formatted_damage_dealt + "\n"
	result += "- DAMAGE RECEIVED: " + GameManager.MY_PLAYER.statistics.formatted_damage_received + "\n"
	result += "- GOLD EARNED: " + GameManager.MY_PLAYER.statistics.formatted_earned_gold + "\n"

	_label.text = result
