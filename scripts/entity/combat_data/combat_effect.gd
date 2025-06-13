class_name CombatEffect

extends Node

const SCENE = preload("res://scenes/entity/combat_data/combat_effect.tscn")
var effect_name: String
var unique_name_node: String
var is_permanent: bool = false
@export var _duration: float # In seconds
var _elapsed: float = 0.0
var _region_rect: Rect2
var max_stacks: int = 1
var stats: CombatStats = CombatStats.new()

const STUN_RECT_REGION := Rect2(0, 608, 32, 17)

func _process(delta: float) -> void:
	if is_permanent: return

	_elapsed += delta
	if _elapsed >= _duration:
		if multiplayer.is_server():
			queue_free() # Only executed on the server

func get_description() -> String:
	var description = ""
	if _duration > 0.0:
		description += str("- Duration: ", StringHelpers.format_float(_duration), "s\n")

	description += stats.get_description()

	description += str("- Max stacks: ", max_stacks, "\n")

	return description

# region 	SETTERs

func set_region_rect(rect: Rect2) -> void:
	_region_rect = rect

func delete_effect() -> void:
	queue_free()
# endregion GETTERs


# region 	GETTERs

# endregion GETTERs


static func get_instance_from_dict(dict: Dictionary) -> CombatEffect:
	var combat_effect = SCENE.instantiate()
	ObjectHelpers.from_dict(combat_effect, dict)
	return combat_effect

static func _get_instance(p_name: String, duration: float, p_is_permanent: bool, _max_stacks: int, _stats: CombatStats) -> CombatEffect:
	var combat_effect = SCENE.instantiate()
	combat_effect.max_stacks = _max_stacks
	if _stats: combat_effect.stats = _stats
	combat_effect._duration = duration
	combat_effect.is_permanent = p_is_permanent
	combat_effect.unique_name_node = StringHelpers.unique_id()
	combat_effect.effect_name = p_name
	return combat_effect

static func get_permanent_effect(p_name: String, _max_stacks: int, _stats: CombatStats) -> CombatEffect:
	return _get_instance(p_name, 0.0, true, _max_stacks, _stats)

static func get_temporal_effect(p_name: String, duration: float, _max_stacks: int, _stats: CombatStats) -> CombatEffect:
	return _get_instance(p_name, duration, false, _max_stacks, _stats)

static func actions_after_effective_hit(_attacker: Entity, _receiver: Entity, _di: DamageInfo) -> void:
	# Should be called only on the server
	var _attacker_stats = _attacker.combat_data.get_total_stats()

	# Stun verification, we need it after the evasion check
	if GlobalsEntityHelpers.roll_chance(_attacker_stats.stun_chance):
		var _stats = CombatStats.new()
		_stats.stun_duration = _attacker_stats.stun_duration
		_stats.is_owner_friendly = false
		var effect = CombatEffect.get_temporal_effect("Stun", _stats.stun_duration, 1, _stats)
		effect.set_region_rect(CombatEffect.STUN_RECT_REGION)
		_receiver.combat_data.add_effect(effect)

	# Lifesteal verification
	if _attacker.combat_data.current_hp < _attacker.combat_data.get_total_hp() && _di.total_damage_heal > 0:
		var _attacker_life_steal_percent = _attacker.combat_data.get_total_stats().life_steal_percent
		if _attacker_life_steal_percent > 0:
			var total_heal = int(_di.total_damage_heal * _attacker_life_steal_percent)
			if total_heal > 0:
				var new_di = DamageInfo.get_instance()
				new_di.total_damage_heal = - total_heal
				_attacker.rpc("rpc_receive_damage_or_heal", ObjectHelpers.to_dict(new_di, true))
				_attacker.combat_data.update_current_hp(total_heal)

	return
