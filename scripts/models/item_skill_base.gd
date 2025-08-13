class_name ItemSkillBase

extends CombatStats

const FRAME_SIZE = 64
const CAN_USE_COLOR = Color.WHITE
const CANT_USE_COLOR = Color(0.5, 0.5, 0.5)

var is_consumable: bool = false
var apply_to_enemy: bool = true
var cast_range_in_tiles: int = 0
var area_of_effect_in_tiles: int = 0
var instant_use: bool = false
var auxiliary_float: float # Used for general purposes, like calculate percentage of damage respect to the strength
var float_dict: Dictionary[String, float] = {} # Used for general purposes, like apply damage after xx seconds
var string_dict: Dictionary = {} # Used for general purposes
var my_name: String
var duration_in_seconds: float
var type: String = SkillType.ACTIVE
var cooldown: float = 0 # In seconds
var mana_cost: int = 0
var en_description: String = ""
var es_description: String = ""
var max_stacks: int = 1
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
	_last_used_time = MainScene.get_elapsed_time_in_sec()

func get_last_used_time() -> float:
	return _last_used_time

func get_description(include_stats_description: bool = true) -> String:
	var result = ""

	if en_description: result += en_description if LanguageManager.is_english() else es_description + "\n"
	
	if include_stats_description and not is_consumable:
		var stats_description: String = super.get_new_description()
		if stats_description: result += "\n" + stats_description
		
	if include_stats_description: result += _internal_description()

	return result

func _internal_description() -> String:
	var result := ""

	if duration_in_seconds > 0:
		result += "- " + LanguageManager.translate("Duration") + ": " + StringHelpers.format_float_compact(duration_in_seconds) + "s\n"

	if area_of_effect_in_tiles > 0:
		result += "- " + LanguageManager.translate("Area of Effect") + ": " + str(area_of_effect_in_tiles) + " " + LanguageManager.translate("tiles") + "\n"

	if cast_range_in_tiles > 0:
		result += "- " + LanguageManager.translate("Cast Range") + ": " + str(cast_range_in_tiles) + " " + LanguageManager.translate("tiles") + "\n"

	if mana_cost > 0:
		result += "- " + LanguageManager.translate("Mana Cost") + ": " + str(mana_cost) + "\n"

	if cooldown > 0.0:
		result += "- " + LanguageManager.translate("Cooldown") + ": " + StringHelpers.format_float_compact(cooldown) + "s\n"

	if max_targets > 1:
		result += "- " + LanguageManager.translate("Max Targets") + ": " + str(max_targets) + "\n"

	if max_stacks > 1:
		result += "- " + LanguageManager.translate("Max Stacks") + ": " + str(max_stacks) + "\n"

	if damage_type != DamageType.NONE:
		result += "- " + LanguageManager.translate("Damage Type") + ": " + str(damage_type) + "\n"

	if not result.is_empty():
		result = "\n" + result

	return result


func can_use(my_owner: Entity) -> bool:
	if mana_cost > 0:
		if my_owner.current_mana < mana_cost: return false

	return get_remaining_cooldown() == 0

var _last_frozen_time: float
func get_remaining_cooldown() -> float:
	if MainScene.PAUSED: return _last_frozen_time
	var now := MainScene.get_elapsed_time_in_sec()
	var elapsed := now - _last_used_time
	_last_frozen_time = max(0.0, cooldown - elapsed)
	return _last_frozen_time

# region -------- STATICS METHODS
static func roll_true_strike(_attacker: Entity, _di: DamageInfo) -> void:
	if _di.damage_type != DamageType.PHYSICAL: return
	if not _di.is_main_attack(): return
	if ObjectHelpers.is_null(_attacker): return

	_di.can_be_evaded = not GlobalsEntityHelpers.roll_chance(_attacker.cache_total_stats.get_chance_to_ignore_evasion())

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if ObjectHelpers.is_null(_attacker): return
	if not _di.is_main_attack(): return
	
	# Stun verification, we need it after the evasion check
	_try_apply_stun(_attacker, _target, _di)

static func static_actions_after_apply_defenses(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not ObjectHelpers.valid_instance(_attacker): return
	if _di.is_zero_damage(): return
	if not _di.is_main_attack(): return

	var _attacker_stats = _attacker.cache_total_stats
	# Cleave verification
	_try_apply_cleave(_attacker, _target, _di)

	# Lifesteal verification
	_try_apply_lifesteal(_attacker, _target, _di)

# endregion STATICS METHODS

# region -------- AUXILIARY METHODS
static func _try_apply_stun(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not _di.is_main_attack() or not _di.is_physical_damage(): return
	if GlobalsEntityHelpers.roll_chance(_attacker.cache_total_stats.get_stun_chance()):
		_target.apply_stun(_attacker.cache_total_stats.get_stun_duration())

static func _try_apply_lifesteal(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not _di.is_main_attack() or not _di.is_physical_damage(): return
	if _attacker.cache_total_stats.get_life_steal_percent() <= 0: return

	if _attacker.current_hp == _attacker.get_full_health() or _di.total_damage <= 0: return

	var total_heal = int(max(1, _di.total_damage * _attacker.cache_total_stats.get_life_steal_percent()))
	if total_heal <= 0: return

	var new_di = DamageInfo.get_instance()
	new_di.total_damage = - total_heal
	_attacker.global_receive_damage_or_heal(new_di)
	_attacker.update_current_hp(total_heal)

static func _try_apply_cleave(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not _di.is_main_attack() or not _di.is_physical_damage(): return
	if _attacker.cache_total_stats.get_cleave_percent() <= 0: return

	var _cleave_range_in_tiles = _attacker.cache_total_stats.get_cleave_range()
	var _cleave_percent = _attacker.cache_total_stats.get_cleave_percent()
	CleaveEffect.show_cleave_effect_with_texture(
		GameManager.game_world.over_terrain_layer_layer_2,
		_target.global_position,
		_attacker.get_direction_according_to_target(_target),
		_cleave_range_in_tiles,
	)

	var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_target.global_position, _attacker.get_my_enemies(), _cleave_range_in_tiles, 100, [_target])
	var filtered_enemies := GlobalsEntityHelpers.filter_enemies_according_to_caster_direction(_attacker.position, _target.position, nearest_enemies)

	if filtered_enemies.is_empty(): return

	var cleave_damage: int = int(_di.total_damage * _cleave_percent)

	for enemy in filtered_enemies:
		var _cdi := DamageInfo.new(cleave_damage, _di.damage_type, _attacker.name)
		_cdi.projectile_type = ProjectileBase.NONE
		_cdi.can_be_evaded = false
		_cdi.was_a_cleave_damage = true
		enemy.server_receive_damage(_cdi, _attacker)
	
# endregion AUXILIARY METHODS