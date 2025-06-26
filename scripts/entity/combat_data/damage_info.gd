class_name DamageInfo

var total_damage: int # Positive for damage, negative for heal
var critical: int
var projectile_type: String
var damage_type: String = DamageType.PHYSICAL
var attacker_name: String
var can_be_evaded: bool = true
var was_reflected: bool = false
var was_a_cleave_damage: bool = false

func _init(p_total_damage: int = 0, _damage_type: String = DamageType.PHYSICAL):
	total_damage = p_total_damage
	damage_type = _damage_type

func get_attacker() -> Entity:
	return GameManager.get_entity(attacker_name)

static func get_instance() -> DamageInfo:
	return DamageInfo.new()