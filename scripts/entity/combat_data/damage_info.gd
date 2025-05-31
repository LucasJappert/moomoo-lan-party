class_name DamageInfo

enum DamageType {
	PHYSICAL,
	MAGIC
}

var total_damage_heal: int # Positive for damage, negative for heal
var critical: int
var projectile_type: String
var damage_type: int = DamageType.PHYSICAL

func to_dict() -> Dictionary:
	return {
		"total_damage_heal": total_damage_heal,
		"critical": critical,
		"projectile_type": projectile_type,
		"damage_type": damage_type
	}

func from_dict(data: Dictionary) -> void:
	total_damage_heal = data.get("total_damage_heal", 0)
	critical = data.get("critical", 0)
	projectile_type = data.get("projectile_type", "")
	damage_type = data.get("damage_type", DamageType.PHYSICAL)

static func get_instance() -> DamageInfo:
	var damage_info = DamageInfo.new()
	return damage_info