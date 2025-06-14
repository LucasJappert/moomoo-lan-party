class_name CustomDamageHeal

var base_damage_heal: int = 0
var extra_value_by_intelligence: float = 0
var extra_value_by_agility: float = 0
var extra_value_by_strength: float = 0


func accumulate_props(other: CustomDamageHeal) -> void:
	base_damage_heal += other.base_damage_heal
	extra_value_by_intelligence += other.extra_value_by_intelligence
	extra_value_by_agility += other.extra_value_by_agility
	extra_value_by_strength += other.extra_value_by_strength

func get_extra_value_by_attributes(agility: int, strength: int, intelligence: int) -> int:
	return int(extra_value_by_intelligence * intelligence + extra_value_by_agility * agility + extra_value_by_strength * strength)

func get_total_damage_heal(agility: int, strength: int, intelligence: int) -> int:
	return base_damage_heal + get_extra_value_by_attributes(agility, strength, intelligence)
