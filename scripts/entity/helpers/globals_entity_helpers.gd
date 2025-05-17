class_name GlobalsEntityHelpers


static func is_target_entity_in_attack_area(_entity: Entity) -> bool:
	if _entity.target_entity == null:
		return false

	var result = _entity.area_attack.overlaps_body(_entity.target_entity)
	return result