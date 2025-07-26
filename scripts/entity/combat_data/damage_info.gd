class_name DamageInfo

var total_damage: int # Positive for damage, negative for heal
var critical: int
var projectile_type: String = ProjectileBase.NONE
var damage_type: String = DamageType.PHYSICAL
var attacker_name: String
var can_be_evaded: bool = true
var was_reflected: bool = false
var temporal_damage: bool = false
var was_a_cleave_damage: bool = false

func _init(p_total_damage: int = 0, _damage_type: String = DamageType.PHYSICAL, _attacker_name: String = ""):
	total_damage = p_total_damage
	damage_type = _damage_type
	attacker_name = _attacker_name

func get_attacker() -> Entity:
	return GameManager.get_entity(attacker_name)

func is_arrow_attack() -> bool:
	if not is_main_attack(): return false
	return projectile_type == ProjectileArrow.NAME and damage_type == DamageType.PHYSICAL

func is_melee_attack() -> bool:
	if not is_main_attack(): return false
	return projectile_type == ProjectileBase.NONE and damage_type == DamageType.PHYSICAL

func is_main_attack() -> bool:
	if was_a_cleave_damage or was_reflected or temporal_damage: return false
	return true
func is_physical_damage() -> bool:
	return damage_type == DamageType.PHYSICAL

static func get_instance() -> DamageInfo:
	return DamageInfo.new()
