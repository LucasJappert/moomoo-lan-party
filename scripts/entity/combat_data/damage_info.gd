class_name DamageInfo

var total_damage_heal: int # Positive for damage, negative for heal
var critical: int
var projectile_type: String
var damage_type: String = DamageType.PHYSICAL
var attacker_name: String

func _init(total_damage: int = 0, _damage_type: String = DamageType.PHYSICAL):
	total_damage_heal = total_damage
	damage_type = _damage_type

func get_attacker() -> Entity:
	return GameManager.get_entity(attacker_name)

static func get_instance() -> DamageInfo:
	return DamageInfo.new()