class_name CleaveEffect

extends MyInitAuxiliary

var damage_type: String
var percent: float
var radius_in_tiles: int = 1

func _init(_percent: float = 0, _radius: int = 1, _damage_type: String = DamageType.PHYSICAL):
	super._init()
	percent = _percent
	radius_in_tiles = _radius
	damage_type = _damage_type

func get_cleave_damage(base_damage: int) -> int:
	return int(base_damage * percent)

func get_description() -> String:
	return str("- Cleave percent: ", StringHelpers.format_percent(percent), " (radius: ", radius_in_tiles, ") \n")

static func auxiliary_actions_after_hit(stats: CombatStats, _attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not stats.cleave_effect: return

	var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_target.global_position, 30, _attacker.get_my_enemies(), stats.cleave_effect.radius_in_tiles, [_target])

	if nearest_enemies.size() == 0: return

	var _cdi := DamageInfo.new(stats.cleave_effect.get_cleave_damage(_di.total_damage), _di.damage_type)
	_cdi.projectile_type = ProjectileBase.NONE
	_cdi.attacker_name = _attacker.name
	_cdi.can_be_evaded = false
	_cdi.was_a_cleave_damage = true
	for enemy in nearest_enemies: enemy.server_receive_damage(_cdi, _attacker)