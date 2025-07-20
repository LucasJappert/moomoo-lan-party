class_name EnemyWardenOfDecay

extends EnemyBase

const LONG_NAME = "Warden of Decay"
const ALIAS = "Decaywarden"
const SPRITES_POS_VECTOR = Vector2i(1, 0)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.crit_chance = 0.1
	_enemy.combat_stats.crit_multiplier = 1.5
