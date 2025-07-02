class_name ItemSkillBase

extends MyInitAuxiliary

const FRAME_SIZE = 64
const CAN_USE_COLOR = Color.WHITE
const CANT_USE_COLOR = Color(0.5, 0.5, 0.5)

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
var apply_to_owner: bool = true
var create_effect: bool = false
var _last_used_time: float = - INF

func _init():
	super._init()

func set_last_used_time() -> void:
	_last_used_time = Time.get_ticks_msec() / 1000.0

func get_description(include_stats_description: bool = true) -> String:
	var result = ""

	if description: result += description + "\n"
	
	if include_stats_description: result += stats.get_description()
	
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
