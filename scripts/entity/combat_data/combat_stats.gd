class_name CombatStats

extends Node

const MIN_ATTACK_RANGE: int = int(sqrt(pow(MapManager.TILE_SIZE.x, 2) + pow(MapManager.TILE_SIZE.y, 2))) + 1

@export var hp: int = 0
@export var mana: int = 0
@export var physical_defense_percent: float = 0
@export var magic_defense_percent: float = 0
@export var evasion: float = 0.0
@export var crit_chance: float = 0.0
@export var crit_multiplier: float = 0
@export var stun_chance: float = 0.0
@export var stun_duration: float = 0.0
@export var attack_range: int = 0
@export var attack_speed: float = 0 # Attacks per second
@export var physical_attack_power: int = 0
@export var physical_attack_power_percent: float = 0
@export var magic_attack_power: int = 0
@export var magic_attack_power_percent: float = 0
@export var freeze_duration: float = 0 # In seconds
@export var move_speed: float = 0 # Tiles per second
@export var attack_speed_percent: float = 0
@export var move_speed_percent: float = 0
@export var life_steal_percent: float = 0
@export var hp_regeneration_points: float = 0 # Points per second
@export var mana_regeneration_points: float = 0 # Points per second

@export var agility: int = 0
@export var strength: int = 0
@export var intelligence: int = 0


static func get_default_instance() -> CombatStats:
	var attr = CombatStats.new()
	attr.move_speed = 3 # Default move speed for enemies
	attr.attack_range = CombatStats.MIN_ATTACK_RANGE
	attr.magic_attack_power = 0
	attr.physical_attack_power = 10
	attr.crit_multiplier = 1.5
	attr.attack_speed = 0.5
	return attr

func accumulate_combat_stats(stats: CombatStats) -> void:
	hp += stats.hp
	mana += stats.mana
	physical_defense_percent += stats.physical_defense_percent
	magic_defense_percent += stats.magic_defense_percent
	evasion += stats.evasion
	crit_chance += stats.crit_chance
	crit_multiplier += stats.crit_multiplier
	stun_chance += stats.stun_chance
	stun_duration += stats.stun_duration
	attack_range += stats.attack_range
	physical_attack_power += stats.physical_attack_power
	magic_attack_power += stats.magic_attack_power
	freeze_duration += stats.freeze_duration
	attack_speed += stats.attack_speed
	move_speed += stats.move_speed
	attack_speed_percent += stats.attack_speed_percent
	move_speed_percent += stats.move_speed_percent
	magic_attack_power_percent += stats.magic_attack_power_percent
	physical_attack_power_percent += stats.physical_attack_power_percent
	life_steal_percent += stats.life_steal_percent
	hp_regeneration_points += stats.hp_regeneration_points
	mana_regeneration_points += stats.mana_regeneration_points

	agility += stats.agility
	strength += stats.strength
	intelligence += stats.intelligence

func initialize_default_values() -> void:
	accumulate_combat_stats(get_default_instance())
	
func get_combat_stats_instance() -> CombatStats:
	var result = CombatStats.new()
	result.accumulate_combat_stats(self)
	return result

func get_total_stats_including_extras_by_attributes() -> CombatStats:
	# This function adds certain values according to the attributes strength, agility, and intelligence, such as hp, mana, damage, etc.
	var result = CombatStats.new()
	result.accumulate_combat_stats(self)
	result.accumulate_combat_stats(_get_extra_stats_by_attributes())
	return result

func _get_extra_stats_by_attributes() -> CombatStats:
	var attr = CombatStats.new()
	attr.accumulate_combat_stats(get_extra_stats_by_strength(strength))
	attr.accumulate_combat_stats(get_extra_stats_by_agility(agility))
	attr.accumulate_combat_stats(get_extra_stats_by_intelligence(intelligence))
	return attr

static func get_extra_stats_by_strength(_str: int) -> CombatStats:
	var attr = CombatStats.new()
	attr.hp = _str * 20
	attr.hp_regeneration_points = _str * 0.1
	attr.physical_attack_power = _str
	return attr

static func get_extra_stats_by_intelligence(_int: int) -> CombatStats:
	var attr = CombatStats.new()
	attr.mana = _int * 12
	attr.mana_regeneration_points = _int * 0.1
	attr.magic_attack_power = _int
	return attr

static func get_extra_stats_by_agility(_agi: int) -> CombatStats:
	var attr = CombatStats.new()
	attr.attack_speed = _agi * 0.1
	attr.evasion = _agi * 0.001 # 1000 of agility = 1 = 100% evasion
	attr.physical_defense_percent = _agi * 0.001 # 1000 of agility = 1 = 100% defense
	return attr