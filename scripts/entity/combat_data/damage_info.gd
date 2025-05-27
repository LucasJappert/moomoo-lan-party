class_name DamageInfo

enum DamageType {
	PHYSICAL,
	MAGIC
}

var total_damage: int
var critical: int
var projectile_type: String
var damage_type: int = DamageType.PHYSICAL

func to_dict() -> Dictionary:
	return {
		"total_damage": total_damage,
		"critical": critical,
		"projectile_type": projectile_type,
		"damage_type": damage_type
	}

func from_dict(data: Dictionary) -> void:
	total_damage = data.get("total_damage", 0)
	critical = data.get("critical", 0)
	projectile_type = data.get("projectile_type", "")
	damage_type = data.get("damage_type", DamageType.PHYSICAL)

static func get_instance() -> DamageInfo:
	var damage_info = DamageInfo.new()
	return damage_info