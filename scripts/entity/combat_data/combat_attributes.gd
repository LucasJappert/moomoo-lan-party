class_name CombatAttributes

extends Node

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
@export var physical_attack_power: int = 0
@export var physical_attack_power_percent: float = 0
@export var magic_attack_power: int = 0
@export var magic_attack_power_percent: float = 0
@export var freeze_duration: float = 0 # In seconds
@export var attack_speed: int = 0 # Milliseconds between attacks
@export var move_speed: float = 0 # Tiles per second
@export var attack_speed_percent: float = 0
@export var move_speed_percent: float = 0
@export var life_steal_percent: float = 0


static func get_default_instance() -> CombatAttributes:
	var attr = CombatAttributes.new()
	attr.move_speed = 3 # Default move speed for enemies
	attr.attack_range = CombatData.MIN_ATTACK_RANGE
	attr.magic_attack_power = 0
	attr.physical_attack_power = 10
	attr.crit_multiplier = 1.5
	attr.attack_speed = 1000
	return attr

func initialize_from_combat_attributes(combat_attributes: CombatAttributes) -> void:
	hp = combat_attributes.hp
	mana = combat_attributes.mana
	physical_defense_percent = combat_attributes.physical_defense_percent
	magic_defense_percent = combat_attributes.magic_defense_percent
	evasion = combat_attributes.evasion
	crit_chance = combat_attributes.crit_chance
	crit_multiplier = combat_attributes.crit_multiplier
	stun_chance = combat_attributes.stun_chance
	stun_duration = combat_attributes.stun_duration
	attack_range = combat_attributes.attack_range
	physical_attack_power = combat_attributes.physical_attack_power
	magic_attack_power = combat_attributes.magic_attack_power
	freeze_duration = combat_attributes.freeze_duration
	attack_speed = combat_attributes.attack_speed
	move_speed = combat_attributes.move_speed
	attack_speed_percent = combat_attributes.attack_speed_percent
	move_speed_percent = combat_attributes.move_speed_percent
	magic_attack_power_percent = combat_attributes.magic_attack_power_percent
	physical_attack_power_percent = combat_attributes.physical_attack_power_percent
	life_steal_percent = combat_attributes.life_steal_percent

func initialize_default_values() -> void:
	initialize_from_combat_attributes(get_default_instance())
	
func get_combat_attributes() -> CombatAttributes:
	var combat_attributes = CombatAttributes.new()
	combat_attributes.initialize_from_combat_attributes(self)
	return combat_attributes