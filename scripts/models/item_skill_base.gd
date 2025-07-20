class_name ItemSkillBase

extends MyInitAuxiliary

const FRAME_SIZE = 64
const CAN_USE_COLOR = Color.WHITE
const CANT_USE_COLOR = Color(0.5, 0.5, 0.5)

var apply_to_enemy: bool = true
var cast_range_in_tiles: int = 7
var area_of_effect_in_tiles: int = 0
var instant_use: bool = false
var auxiliary_float: float # Used for general purposes, like calculate percentage of damage respect to the strength
var float_dict: Dictionary = {} # Used for general purposes, like apply damage after xx seconds
var string_dict: Dictionary = {} # Used for general purposes
var my_name: String
var duration_in_seconds: float
var type: String = SkillType.ACTIVE
var cooldown: float = 0 # In seconds
var mana_cost: int = 0
var description: String = ""
var max_stacks: int = 1
var stats: CombatStats = CombatStats.new()
var damage_type: String = DamageType.NONE
var max_targets: int = 1
var create_effect: bool = false
var create_effect_to_enemy: bool = false
var _last_used_time: float = - INF

func _init():
	super._init()

func set_last_used_time(p_last_used_time: float) -> void:
	_last_used_time = p_last_used_time

func reset_last_used_time() -> void:
	_last_used_time = Time.get_ticks_msec() / 1000.0

func get_last_used_time() -> float:
	return _last_used_time

func get_description(include_stats_description: bool = true) -> String:
	var result = ""

	if description: result += description + "\n"
	
	if include_stats_description: result += stats.get_description()
	
	if duration_in_seconds > 0:
		result += str("- Duration: ", StringHelpers.format_float_compact(duration_in_seconds), "s\n")

	if area_of_effect_in_tiles > 0:
		result += str("- Area of effect: ", area_of_effect_in_tiles, " tiles\n")

	if cast_range_in_tiles > 0:
		result += str("- Cast range: ", cast_range_in_tiles, " tiles\n")

	if mana_cost > 0:
		result += str("- Mana cost: ", mana_cost, "\n")

	if cooldown > 0.0:
		result += str("- Cooldown: ", StringHelpers.format_float_compact(cooldown), "s\n")

	if max_targets > 1:
		result += "- Max targets: " + str(max_targets) + "\n"

	if max_stacks > 1:
		result += "- Max stacks: " + str(max_stacks) + "\n"

	if damage_type != DamageType.NONE:
		result += "- Damage type: " + str(damage_type) + "\n"

	return result

func can_use(my_owner: Entity) -> bool:
	if mana_cost > 0:
		if my_owner.current_mana < mana_cost: return false

	return get_remaining_cooldown() == 0

func get_remaining_cooldown() -> float:
	var now := Time.get_ticks_msec() / 1000.0
	var elapsed := now - _last_used_time
	return max(0.0, cooldown - elapsed)
