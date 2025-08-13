class_name EnemySummonedSkeletonBow

extends EnemyBase

const LONG_NAME = "Summoned Skeletonbow"
const ALIAS = "Skeletonbow"
const SPRITES_POS_VECTOR = Vector2i(8, 2)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)
