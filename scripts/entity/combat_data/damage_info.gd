class_name DamageInfo

enum DamageType {
	PHYSICAL,
	MAGIC
}

var total_damage_heal: int # Positive for damage, negative for heal
var critical: int
var projectile_type: String
var damage_type: int = DamageType.PHYSICAL
var attacker_name: String

func get_attacker() -> Entity:
	return GameManager.get_entity(attacker_name)

static func get_instance() -> DamageInfo:
	return DamageInfo.new()