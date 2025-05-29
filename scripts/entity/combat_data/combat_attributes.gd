class_name CombatAttributes

extends Node

@export var hp: int = 0
@export var physical_defense_percent: float = 0
@export var magic_defense_percent: float = 0
@export var evasion: float = 0.0
@export var crit_chance: float = 0.0
@export var crit_multiplier: float = 0
@export var stun_chance: float = 0.0
@export var stun_duration: float = 0.0
@export var attack_speed: float = 0 # Higher is faster
@export var attack_range: int = 0
@export var physical_attack_power: int = 0
@export var magic_attack_power: int = 0
@export var has_freeze_effect = false

func initialize_from_object(combat_attributes: CombatAttributes) -> void:
	hp = combat_attributes.hp
	physical_defense_percent = combat_attributes.physical_defense_percent
	magic_defense_percent = combat_attributes.magic_defense_percent
	evasion = combat_attributes.evasion
	crit_chance = combat_attributes.crit_chance
	crit_multiplier = combat_attributes.crit_multiplier
	stun_chance = combat_attributes.stun_chance
	stun_duration = combat_attributes.stun_duration
	attack_speed = combat_attributes.attack_speed
	attack_range = combat_attributes.attack_range
	physical_attack_power = combat_attributes.physical_attack_power
	magic_attack_power = combat_attributes.magic_attack_power
	has_freeze_effect = combat_attributes.has_freeze_effect