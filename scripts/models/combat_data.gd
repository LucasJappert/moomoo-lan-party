class_name CombatData

var max_hp: int = 100
var physical_defense: int = 0
var magic_defense: int = 0
var evasion: float = 0.0
var crit_chance: float = 0.0
var crit_multiplier: float = 1.0
var attack_speed: float = 1.0
var attack_range: int = 0
var attack_type := AttackTypes.MELEE
var projectile_type: String = ""
var skills: Array[Skill] = []

func _init() -> void:
	print("_init CombatData")