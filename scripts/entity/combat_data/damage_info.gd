class_name DamageInfo

var amount: int
var critical: bool
var from_entity_id: int
var to_entity_id: int

func to_dict() -> Dictionary:
	return {
		"amount": amount,
		"critical": critical,
		"from_entity_id": from_entity_id,
		"to_entity_id": to_entity_id,
	}

func from_dict(data: Dictionary) -> void:
	amount = data.get("amount", 0)
	critical = data.get("critical", false)
	from_entity_id = data.get("from_entity_id", -1)
	to_entity_id = data.get("to_entity_id", -1)

static func get_instance(_amount: int, _critical: bool, _from_entity_id: int, _to_entity_id: int) -> DamageInfo:
	var damage_info = DamageInfo.new()
	damage_info.amount = _amount
	damage_info.critical = _critical
	damage_info.from_entity_id = _from_entity_id
	damage_info.to_entity_id = _to_entity_id
	return damage_info