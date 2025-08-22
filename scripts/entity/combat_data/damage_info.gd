class_name DamageInfo

var total_damage: int # Positive for damage, negative for heal
var critical: int
var projectile_type: String = ProjectileBase.NONE
var is_extra_projectile: bool = false
var damage_type: String = DamageType.PHYSICAL
var attacker_name: String
var attacker_key_type: String
var can_be_evaded: bool = true
var was_reflected: bool = false
var temporal_damage: bool = false
var was_a_cleave_damage: bool = false
var is_static_damage: bool = false

func _init(p_total_damage: int = 0, _damage_type: String = DamageType.PHYSICAL, _attacker: Entity = null):
	total_damage = p_total_damage
	damage_type = _damage_type
	if ObjectHelpers.get_safe_instance(_attacker):
		attacker_name = _attacker.name
		attacker_key_type = _attacker.extra_info.key_type


func set_cleave_damage() -> void:
	was_a_cleave_damage = true
	can_be_evaded = false

func set_static_damage() -> void:
	is_static_damage = true
	can_be_evaded = false

func get_attacker() -> Entity:
	return GameManager.get_entity(attacker_name)

func is_arrow_attack() -> bool:
	if not is_main_attack(): return false
	return projectile_type == ProjectileArrow.NAME and damage_type == DamageType.PHYSICAL

func is_melee_attack() -> bool:
	if not is_main_attack(): return false
	return projectile_type == ProjectileBase.NONE and damage_type == DamageType.PHYSICAL

func is_main_attack() -> bool:
	if was_a_cleave_damage or was_reflected or temporal_damage or is_extra_projectile or is_static_damage: return false
	return true
func is_physical_damage() -> bool:
	return damage_type == DamageType.PHYSICAL

func is_zero_damage() -> bool:
	return total_damage == 0 or total_damage == critical

func get_safe_attacker_type() -> String:
	if attacker_key_type: return attacker_key_type
	if was_a_cleave_damage: return LanguageManager.translate("Cleave")
	if was_reflected: return LanguageManager.translate("Reflect")
	if is_static_damage: return LanguageManager.translate("Static")
	if temporal_damage: return LanguageManager.translate("Temporal")
	return LanguageManager.translate("Unknown")

static func get_instance() -> DamageInfo:
	return DamageInfo.new()
