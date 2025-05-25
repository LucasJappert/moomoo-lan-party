class_name DamageInfo

var total_damage: int
var critical: int
var from_entity_id: int
var to_entity_id: int
var projectile_type: String

func to_dict() -> Dictionary:
	return {
		"total_damage": total_damage,
		"critical": critical,
		"from_entity_id": from_entity_id,
		"to_entity_id": to_entity_id,
		"projectile_type": projectile_type
	}

func from_dict(data: Dictionary) -> void:
	total_damage = data.get("total_damage", 0)
	critical = data.get("critical", 0)
	from_entity_id = data.get("from_entity_id", -1)
	to_entity_id = data.get("to_entity_id", -1)
	projectile_type = data.get("projectile_type", "")

static func get_instance(_total_amount: int, _critical: int, _from_entity_id: int, _to_entity_id: int) -> DamageInfo:
	var damage_info = DamageInfo.new()
	damage_info.total_damage = _total_amount
	damage_info.critical = _critical
	damage_info.from_entity_id = _from_entity_id
	damage_info.to_entity_id = _to_entity_id
	return damage_info