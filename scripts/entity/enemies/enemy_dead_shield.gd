class_name EnemyDeadShield

extends EnemyBase

const LONG_NAME = "Dead Shield"
const ALIAS = "Zeke"
const SPRITES_POS_VECTOR = Vector2i(6, 3)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.set_evasion(0.3)
	_enemy.combat_stats.set_attack_speed(1)
	_enemy.combat_stats.set_physical_defense_percent(0.3)
