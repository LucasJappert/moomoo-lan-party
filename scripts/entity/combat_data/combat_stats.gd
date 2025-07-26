class_name CombatStats

extends MyInitAuxiliary

const MIN_ATTACK_RANGE: int = int(sqrt(pow(MapManager.TILE_SIZE.x, 2) + pow(MapManager.TILE_SIZE.y, 2))) + 1

var level: int
static var EMPTY_STATS: CombatStats = CombatStats.new()

var _info: Dictionary[String, float] = {}

const CLEAVE_PERCENT = "cleave_percent"
const CLEAVE_RANGE = "cleave_range" # In tiles

const HP = "hp"
const MANA = "mana"
const PHYSICAL_DEFENSE_PERCENT = "physical_defense_percent"
const MAGIC_DEFENSE_PERCENT = "magic_defense_percent"
const EVASION = "evasion"
const CRIT_CHANCE = "crit_chance"
const CRIT_MULTIPLIER = "crit_multiplier"
const STUN_CHANCE = "stun_chance"
const STUN_DURATION = "stun_duration" # In seconds
const SILENCE_DURATION = "silence_duration" # In seconds
const ATTACK_RANGE = "attack_range"
const PHYSICAL_ATTACK_POWER = "physical_attack_power"
const PHYSICAL_ATTACK_POWER_PERCENT = "physical_attack_power_percent"
const MAGIC_ATTACK_POWER = "magic_attack_power"
const MAGIC_ATTACK_POWER_PERCENT = "magic_attack_power_percent"
const ATTACK_SPEED = "attack_speed" # Attacks per second
const ATTACK_SPEED_PERCENT = "attack_speed_percent"
const MOVE_SPEED = "move_speed" # Tiles per second
const MOVE_SPEED_PERCENT = "move_speed_percent"
const FREEZE_DURATION = "freeze_duration" # In seconds
const LIFE_STEAL_PERCENT = "life_steal_percent"
const HP_REGENERATION_POINTS = "hp_regeneration_points" # Points per second
const HP_REGENERATION_POINTS_PERCENT = "hp_regeneration_points_percent"
const MANA_REGENERATION_POINTS = "mana_regeneration_points" # Points per second
const MANA_REGENERATION_POINTS_PERCENT = "mana_regeneration_points_percent"
const PERCENT_MANA_TO_BURN = "percent_mana_to_burn"
const CHANCE_TO_IGNORE_EVASION = "chance_to_ignore_evasion"
const AGILITY = "agility"
const STRENGTH = "strength"
const INTELLIGENCE = "intelligence"
# ---------------------------------
func _init() -> void:
	super._init()

func accumulate_info(info_to_add: Dictionary[String, float]) -> Dictionary[String, float]:
	for key in info_to_add:
		if _info.has(key):
			_info[key] += info_to_add[key]
		else:
			_info[key] = info_to_add[key]
	return _info

static func aux_accumulate(current: Dictionary[String, float], info_to_add: Dictionary[String, float]) -> Dictionary[String, float]:
	for key in info_to_add:
		if not current.has(key):
			current[key] = info_to_add[key]
			continue

		if key == CLEAVE_RANGE:
			current[key] = max(current[key], info_to_add[key])
			continue
		current[key] += info_to_add[key]
		
	return current

static func get_extra_info_by_attributes(info: Dictionary[String, float]) -> Dictionary[String, float]:
	var result: Dictionary[String, float] = {}
	aux_accumulate(result, get_extra_stats_by_strength(info.get(STRENGTH, 0)))
	aux_accumulate(result, get_extra_stats_by_agility(info.get(AGILITY, 0)))
	aux_accumulate(result, get_extra_stats_by_intelligence(info.get(INTELLIGENCE, 0)))
	return result

# ---------------------------------

static func get_instance_from_dict(dict: Dictionary) -> CombatStats:
	var instance = CombatStats.new()
	ObjectHelpers.from_dict(instance, dict)
	return instance

const _HP_BY_STRENGTH = 20; const _HP_REGEN_BY_STRENGTH = 0.1; const _PHYSICAL_ATTACK_POWER_BY_STRENGTH = 0.5
static var STRENGTH_PROPERTIES = "Gives " + StringHelpers.format_float(_HP_BY_STRENGTH) + " hp, " + \
	StringHelpers.format_float(_HP_REGEN_BY_STRENGTH) + " hp regen and " + \
	StringHelpers.format_float(_PHYSICAL_ATTACK_POWER_BY_STRENGTH) + " physical attack power per point of strength"
static func get_extra_stats_by_strength(_str: int) -> Dictionary[String, float]:
	var result: Dictionary[String, float] = {}
	result[HP] = _str * _HP_BY_STRENGTH
	result[HP_REGENERATION_POINTS] = _str * _HP_REGEN_BY_STRENGTH
	result[PHYSICAL_ATTACK_POWER] = _str * _PHYSICAL_ATTACK_POWER_BY_STRENGTH
	return result

const _MANA_BY_INTELLIGENCE = 10; const _MANA_REGEN_BY_INTELLIGENCE = 0.05; const _MAGIC_ATTACK_POWER_BY_INTELLIGENCE = 0.25
const _MAGIC_DEFENSE_BY_INTELLIGENCE = 1 / _AUX
static var INTELLIGENCE_PROPERTIES = "Gives " + StringHelpers.format_float(_MANA_BY_INTELLIGENCE) + " mana, " + \
	StringHelpers.format_float(_MANA_REGEN_BY_INTELLIGENCE) + " mana regen, " + \
	StringHelpers.format_float(_MAGIC_ATTACK_POWER_BY_INTELLIGENCE) + " magic attack power and " + \
	StringHelpers.format_percent(_MAGIC_DEFENSE_BY_INTELLIGENCE, true, 1) + " magic defense per point of intelligence"
static func get_extra_stats_by_intelligence(_int: int) -> Dictionary[String, float]:
	var result: Dictionary[String, float] = {}
	result[MANA] = _int * _MANA_BY_INTELLIGENCE
	result[MANA_REGENERATION_POINTS] = _int * _MANA_REGEN_BY_INTELLIGENCE
	result[MAGIC_ATTACK_POWER] = _int * _MAGIC_ATTACK_POWER_BY_INTELLIGENCE
	result[MAGIC_DEFENSE_PERCENT] = _int * _MAGIC_DEFENSE_BY_INTELLIGENCE
	return result

const _AUX: float = 1000
const _ATTACK_SPEED_BY_AGILITY: float = 1 / _AUX
const _EVASION_BY_AGILITY: float = 1 / _AUX
const _DEFENSE_BY_AGILITY: float = 1 / _AUX
static var AGILITY_PROPERTIES = "Gives " + StringHelpers.format_percent(_ATTACK_SPEED_BY_AGILITY, true, 1) + " attack speed, " + \
	StringHelpers.format_percent(_EVASION_BY_AGILITY, true, 1) + " evasion and " + \
	StringHelpers.format_percent(_DEFENSE_BY_AGILITY, true, 1) + " defense per point of agility"
static func get_extra_stats_by_agility(_agi: int) -> Dictionary[String, float]:
	var result: Dictionary[String, float] = {}
	result[ATTACK_SPEED] = _agi * _ATTACK_SPEED_BY_AGILITY # 1000 of agility = 1 = Cada segundo 1 ataque
	result[EVASION] = _agi * _EVASION_BY_AGILITY # 1000 of agility = 1 = 100% evasion
	result[PHYSICAL_DEFENSE_PERCENT] = _agi * _DEFENSE_BY_AGILITY # 1000 of agility = 1 = 100% defense
	return result


# region 	SETTERs
func set_info(info: Dictionary[String, float]) -> void:
	_info = info
func set_value(prop: String, value: float) -> void:
	_info[prop] = value
func set_value_i(prop: String, value: int) -> void:
	_info[prop] = value

func set_cleave_percent(value: float) -> void:
	set_value(CLEAVE_PERCENT, value)
func set_cleave_range(value: int) -> void:
	set_value_i(CLEAVE_RANGE, value)
func set_hp(value: int) -> void:
	set_value_i(HP, value)
func set_mana(value: int) -> void:
	set_value_i(MANA, value)
func set_physical_defense_percent(value: float) -> void:
	set_value(PHYSICAL_DEFENSE_PERCENT, value)
func set_magic_defense_percent(value: float) -> void:
	set_value(MAGIC_DEFENSE_PERCENT, value)
func set_evasion(value: float) -> void:
	set_value(EVASION, value)
func set_crit_chance(value: float) -> void:
	set_value(CRIT_CHANCE, value)
func set_crit_multiplier(value: float) -> void:
	set_value(CRIT_MULTIPLIER, value)
func set_stun_chance(value: float) -> void:
	set_value(STUN_CHANCE, value)
func set_stun_duration(value: float) -> void:
	set_value(STUN_DURATION, value)
func set_silence_duration(value: float) -> void:
	set_value(SILENCE_DURATION, value)
func set_attack_range(value: int) -> void:
	set_value_i(ATTACK_RANGE, value)
func set_physical_attack_power(value: int) -> void:
	set_value_i(PHYSICAL_ATTACK_POWER, value)
func set_physical_attack_power_percent(value: float) -> void:
	set_value(PHYSICAL_ATTACK_POWER_PERCENT, value)
func set_magic_attack_power(value: int) -> void:
	set_value_i(MAGIC_ATTACK_POWER, value)
func set_magic_attack_power_percent(value: float) -> void:
	set_value(MAGIC_ATTACK_POWER_PERCENT, value)
func set_attack_speed(value: float) -> void:
	set_value(ATTACK_SPEED, value)
func set_attack_speed_percent(value: float) -> void:
	set_value(ATTACK_SPEED_PERCENT, value)
func set_move_speed(value: float) -> void:
	set_value(MOVE_SPEED, value)
func set_move_speed_percent(value: float) -> void:
	set_value(MOVE_SPEED_PERCENT, value)
func set_freeze_duration(value: float) -> void:
	set_value(FREEZE_DURATION, value)
func set_life_steal_percent(value: float) -> void:
	set_value(LIFE_STEAL_PERCENT, value)
func set_hp_regeneration_points(value: int) -> void:
	set_value_i(HP_REGENERATION_POINTS, value)
func set_hp_regeneration_points_percent(value: float) -> void:
	set_value(HP_REGENERATION_POINTS_PERCENT, value)
func set_mana_regeneration_points(value: int) -> void:
	set_value_i(MANA_REGENERATION_POINTS, value)
func set_mana_regeneration_points_percent(value: float) -> void:
	set_value(MANA_REGENERATION_POINTS_PERCENT, value)
func set_percent_mana_to_burn(value: float) -> void:
	set_value(PERCENT_MANA_TO_BURN, value)
func set_chance_to_ignore_evasion(value: float) -> void:
	set_value(CHANCE_TO_IGNORE_EVASION, value)
func set_agility(value: int) -> void:
	set_value_i(AGILITY, value)
func set_strength(value: int) -> void:
	set_value_i(STRENGTH, value)
func set_intelligence(value: int) -> void:
	set_value_i(INTELLIGENCE, value)
# endregion SETTERs

# region 	GETTERs
func _get_value(key: String) -> float:
	return _info.get(key, 0)
func _get_value_i(key: String) -> int:
	return _info.get(key, 0)

func get_info() -> Dictionary[String, float]:
	return _info
	
func get_total_info_including_extras_by_attributes() -> Dictionary[String, float]:
	var result: Dictionary[String, float] = {}
	aux_accumulate(result, _info)
	aux_accumulate(result, get_extra_info_by_attributes(result))
	return result

func grants_defenses() -> bool:
	if get_physical_defense_percent() > 0: return true
	if get_magic_defense_percent() > 0: return true
	if get_evasion() > 0: return true
	if get_hp_regeneration_points() > 0 or get_hp_regeneration_points_percent() > 0: return true
	if get_mana_regeneration_points() > 0 or get_mana_regeneration_points_percent() > 0: return true
	return false

func grants_attack_bonuses() -> bool:
	if get_physical_attack_power() > 0 or get_physical_attack_power_percent() > 0: return true
	if get_magic_attack_power() > 0 or get_magic_attack_power_percent() > 0: return true
	if get_attack_speed() > 0 or get_attack_speed_percent() > 0: return true
	if get_crit_chance() > 0: return true
	if get_stun_chance() > 0: return true
	if get_life_steal_percent() > 0: return true
	return false

func hostile_stun() -> bool:
	return get_stun_duration() > 0 && get_stun_chance() == 0
func hostile_silence() -> bool:
	return get_silence_duration() > 0
func hostile_freeze() -> bool:
	return get_freeze_duration() > 0

func get_description() -> String:
	var description = ""

	if get_hp() != 0:
		description += str("- HP: ", get_hp(), "\n")
	
	if get_mana() != 0:
		description += str("- Mana: ", get_mana(), "\n")

	if get_physical_defense_percent() != 0:
		description += str("- Physical defense percent: ", StringHelpers.format_percent(get_physical_defense_percent()), "\n")

	if get_magic_defense_percent() != 0:
		description += str("- Magic defense percent: ", StringHelpers.format_percent(get_magic_defense_percent()), "\n")

	if get_evasion() != 0:
		description += str("- Evasion: ", StringHelpers.format_percent(get_evasion()), "\n")

	if get_crit_chance() != 0:
		description += str("- Crit chance: ", StringHelpers.format_percent(get_crit_chance()), "\n")

	if get_crit_multiplier() != 0:
		description += str("- Crit multiplier: ", StringHelpers.format_float_compact(get_crit_multiplier()), "\n")

	if get_stun_chance() != 0:
		description += str("- Stun chance: ", StringHelpers.format_percent(get_stun_chance()), "\n")

	if get_stun_duration() != 0:
		description += str("- Stun duration: ", StringHelpers.format_float_compact(get_stun_duration()), "s\n")

	if get_attack_range() != 0:
		description += str("- Attack range: ", get_attack_range(), "\n")

	if get_physical_attack_power() != 0:
		description += str("- Physical attack power: ", get_physical_attack_power(), "\n")

	if get_physical_attack_power_percent() != 0:
		description += str("- Physical attack power percent: ", StringHelpers.format_percent(get_physical_attack_power_percent()), "\n")

	if get_magic_attack_power() != 0:
		description += str("- Magic attack power: ", get_magic_attack_power(), "\n")

	if get_magic_attack_power_percent() != 0:
		description += str("- Magic attack power percent: ", StringHelpers.format_percent(get_magic_attack_power_percent()), "\n")

	if get_attack_speed() != 0:
		description += str("- Attack speed: ", StringHelpers.format_float_compact(get_attack_speed()), "\n")

	if get_attack_speed_percent() != 0:
		description += str("- Attack speed percent: ", StringHelpers.format_percent(get_attack_speed_percent()), "\n")

	if get_move_speed() != 0:
		description += str("- Move speed: ", StringHelpers.format_float_compact(get_move_speed()), "\n")

	if get_move_speed_percent() != 0:
		description += str("- Move speed percent: ", StringHelpers.format_percent(get_move_speed_percent()), "\n")

	if get_freeze_duration() != 0:
		description += str("- Freeze duration: ", StringHelpers.format_float_compact(get_freeze_duration()), "\n")

	if get_life_steal_percent() != 0:
		description += str("- Life steal percent: ", StringHelpers.format_percent(get_life_steal_percent()), "\n")

	if get_hp_regeneration_points() != 0:
		description += str("- HP regeneration points: ", get_hp_regeneration_points(), "\n")

	if get_hp_regeneration_points_percent() != 0:
		description += str("- HP regeneration points percent: ", StringHelpers.format_percent(get_hp_regeneration_points_percent(), true, 1), "\n")

	if get_mana_regeneration_points() != 0:
		description += str("- Mana regeneration points: ", get_mana_regeneration_points(), "\n")

	return description

func get_cleave_percent() -> float: return _get_value(CLEAVE_PERCENT)
func get_cleave_range() -> int: return _get_value_i(CLEAVE_RANGE)
func get_hp() -> int: return _get_value_i(HP)
func get_mana() -> int: return _get_value_i(MANA)
func get_physical_defense_percent() -> float: return _get_value(PHYSICAL_DEFENSE_PERCENT)
func get_magic_defense_percent() -> float: return _get_value(MAGIC_DEFENSE_PERCENT)
func get_evasion() -> float: return _get_value(EVASION)
func get_crit_chance() -> float:
	return _get_value(CRIT_CHANCE)
func get_crit_multiplier() -> float:
	return _get_value(CRIT_MULTIPLIER)
func get_stun_chance() -> float:
	return _get_value(STUN_CHANCE)
func get_stun_duration() -> float:
	return _get_value(STUN_DURATION)
func get_silence_duration() -> float:
	return _get_value(SILENCE_DURATION)
func get_attack_range() -> int:
	return _get_value_i(ATTACK_RANGE)
func get_physical_attack_power() -> int:
	return int(_get_value_i(PHYSICAL_ATTACK_POWER) * (1 + _get_value(PHYSICAL_ATTACK_POWER_PERCENT)))
func get_physical_attack_power_percent() -> float:
	return _get_value(PHYSICAL_ATTACK_POWER_PERCENT)
func get_magic_attack_power() -> int:
	return int(_get_value_i(MAGIC_ATTACK_POWER) * (1 + _get_value(MAGIC_ATTACK_POWER_PERCENT)))
func get_magic_attack_power_percent() -> float:
	return _get_value(MAGIC_ATTACK_POWER_PERCENT)
func get_attack_speed() -> float:
	return _get_value(ATTACK_SPEED)
func get_attack_speed_percent() -> float:
	return _get_value(ATTACK_SPEED_PERCENT)
func get_move_speed() -> float:
	return _get_value(MOVE_SPEED)
func get_move_speed_percent() -> float:
	return _get_value(MOVE_SPEED_PERCENT)
func get_freeze_duration() -> float:
	return _get_value(FREEZE_DURATION)
func get_life_steal_percent() -> float:
	return _get_value(LIFE_STEAL_PERCENT)
func get_hp_regeneration_points() -> int:
	return _get_value_i(HP_REGENERATION_POINTS)
func get_hp_regeneration_points_percent() -> float:
	return _get_value(HP_REGENERATION_POINTS_PERCENT)
func get_mana_regeneration_points() -> int:
	return _get_value_i(MANA_REGENERATION_POINTS)
func get_mana_regeneration_points_percent() -> float:
	return _get_value(MANA_REGENERATION_POINTS_PERCENT)
func get_percent_mana_to_burn() -> float:
	return _get_value(PERCENT_MANA_TO_BURN)
func get_chance_to_ignore_evasion() -> float:
	return _get_value(CHANCE_TO_IGNORE_EVASION)
func get_agility() -> int:
	return _get_value_i(AGILITY)
func get_strength() -> int:
	return _get_value_i(STRENGTH)
func get_intelligence() -> int:
	return _get_value_i(INTELLIGENCE)

func get_total_move_speed() -> float:
	return clamp(get_move_speed() + (get_move_speed() * get_move_speed_percent()), 1, 20)
func get_total_attack_speed() -> float:
	return clamp(get_attack_speed() + (get_attack_speed() * get_attack_speed_percent()), 0.1, 20)

func get_total_magic_damage(base_damage: int) -> int:
	return int(base_damage * get_magic_power_multiplier())
func get_magic_power_multiplier() -> float:
	return 1.0 + get_magic_attack_power() / 100.0

func get_critic_description() -> String:
	if get_crit_chance() == 0: return ""
	return StringHelpers.format_percent(get_crit_chance()) + " (*" + StringHelpers.format_float_compact(get_crit_multiplier()) + ")"
# endregion GETTERs

# region ---------- STATIC METHODS
# endregion ---------- STATIC METHODS