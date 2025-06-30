class_name ManaBurn

extends MyInitAuxiliary

var mana_burn_percent_by_damage: float = 0.0
var percent_of_extra_damage_per_burned_mana: float = 0
var gain_burned_mana: bool = false

func _init(p_mana_burn_percent_by_damage: float = 0.0, p_percent_of_extra_damage_per_burned_mana: float = 0.0, p_gain_burned_mana: bool = false):
	super._init()
	mana_burn_percent_by_damage = p_mana_burn_percent_by_damage
	percent_of_extra_damage_per_burned_mana = p_percent_of_extra_damage_per_burned_mana
	gain_burned_mana = p_gain_burned_mana

func get_description() -> String:
	return str("- Mana burn percent: ", StringHelpers.format_percent(mana_burn_percent_by_damage), "\n")

func get_mana_burned(base_damage: int) -> int:
	return int(base_damage * mana_burn_percent_by_damage)

func get_extra_damage_by_burned_mana(burned_mana: int) -> int:
	return int(burned_mana * percent_of_extra_damage_per_burned_mana)

static func auxiliary_actions_after_hit(stats: CombatStats, _attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if _di.was_a_cleave_damage: return
	if not stats.mana_burn: return

	var mana_burned = stats.mana_burn.get_mana_burned(_di.total_damage)
	if not mana_burned: return

	_target.combat_data.update_current_mana(-mana_burned)

	var extra_damage_by_burned_mana = stats.mana_burn.get_extra_damage_by_burned_mana(mana_burned)
	var new_total_damage = _di.total_damage + extra_damage_by_burned_mana
	_di.total_damage = new_total_damage