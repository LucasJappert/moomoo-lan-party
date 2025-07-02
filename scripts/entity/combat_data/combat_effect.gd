class_name CombatEffect

extends MyInitAuxiliary

var effect_name: String
var id: int
var is_permanent: bool = false
var _duration_in_seconds: float # In seconds
var _elapsed: float = 0.0
var _region_rect: Rect2
var max_stacks: int = 1
var stats: CombatStats = CombatStats.new()
var unique_id: int = UniqueIdGenerator.get_id()
var is_cooldown_finished: bool = false

const STUN_RECT_REGION := Rect2(0, 608, 32, 17)
const STUN_NAME = "Stun"

func _process(delta: float) -> void:
	if is_permanent: return

	_elapsed += delta
	if _elapsed <= _duration_in_seconds: return

	_elapsed = _duration_in_seconds
	is_cooldown_finished = true
	# EventBus.emit_effect_removed(GlobalsEntityHelpers.get_owner(self), self)

func get_description() -> String:
	var description = ""
	if _duration_in_seconds > 0.0:
		description += str("- Duration: ", StringHelpers.format_float_compact(_duration_in_seconds), "s\n")

	description += stats.get_description()

	description += str("- Max stacks: ", max_stacks, "\n")

	return description

# region 	SETTERs

func set_region_rect(rect: Rect2) -> void:
	_region_rect = rect

# endregion GETTERs


# region 	GETTERs

# endregion GETTERs


static func get_instance_from_dict(dict: Dictionary) -> CombatEffect:
	var combat_effect = CombatEffect.new()
	ObjectHelpers.from_dict(combat_effect, dict)
	return combat_effect

static func _get_instance(p_name: String, duration_in_seconds: float, p_is_permanent: bool, _max_stacks: int, _stats: CombatStats) -> CombatEffect:
	var combat_effect = CombatEffect.new()
	combat_effect.max_stacks = _max_stacks
	if _stats: combat_effect.stats = _stats
	combat_effect._duration_in_seconds = duration_in_seconds
	combat_effect.is_permanent = p_is_permanent
	combat_effect.id = UniqueIdGenerator.get_id()
	combat_effect.effect_name = p_name
	return combat_effect

static func get_permanent_effect(p_name: String, _max_stacks: int, _stats: CombatStats) -> CombatEffect:
	return _get_instance(p_name, 0.0, true, _max_stacks, _stats)

static func get_temporal_effect(p_name: String, duration_in_seconds: float, _max_stacks: int, _stats: CombatStats) -> CombatEffect:
	var result = _get_instance(p_name, duration_in_seconds, false, _max_stacks, _stats)
	if p_name == STUN_NAME: result.set_region_rect(CombatEffect.STUN_RECT_REGION)
	return result

static func actions_after_effective_hit(_attacker: Entity, _receiver: Entity, _di: DamageInfo) -> void:
	# Should be called only on the server
	var _attacker_stats = _attacker.cache_total_stats

	# Stun verification, we need it after the evasion check
	if _di.damage_type == DamageType.PHYSICAL:
		if GlobalsEntityHelpers.roll_chance(_attacker_stats.stun_chance):
			var _stats = CombatStats.new()
			_stats.stun_duration = _attacker_stats.stun_duration
			_stats.is_owner_friendly = false
			var effect = CombatEffect.get_temporal_effect(STUN_NAME, _stats.stun_duration, 1, _stats)
			_receiver.effects_helper.add_effect(effect)

	# Lifesteal verification
	if not _di.was_a_cleave_damage:
		if _attacker.current_hp < _attacker.get_total_hp() && _di.total_damage > 0:
			var _attacker_life_steal_percent = _attacker.cache_total_stats.life_steal_percent
			if _attacker_life_steal_percent > 0:
				var total_heal = int(max(1, _di.total_damage * _attacker_life_steal_percent))
				if total_heal > 0:
					var new_di = DamageInfo.get_instance()
					new_di.total_damage = - total_heal
					_attacker.rpc_handler.receive_damage_or_heal(ObjectHelpers.to_dict(new_di, true))
					_attacker.update_current_hp(total_heal)
	return
