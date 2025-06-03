class_name AttributeTypes

const AGILITY = "Agility"
const STRENGTH = "Strength"
const INTELLIGENCE = "Intelligence"

static func get_extra_attributes(strength: int) -> CombatAttributes:
	var attr = CombatAttributes.new()
	attr.hp = strength * 20
	attr.hp_regeneration_points = strength * 0.1
	return attr
