class_name EnemySummonedSkeletonBlade

extends EnemyBase

const LONG_NAME = "Summoned Skeletonblade"
const ALIAS = "Skeletonblade"
const SPRITES_POS_VECTOR = Vector2i(8, 3)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)
