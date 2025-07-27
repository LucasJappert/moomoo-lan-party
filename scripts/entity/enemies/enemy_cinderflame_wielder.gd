class_name EnemyCinderflameWielder

extends EnemyBase

const LONG_NAME = "Cinderflame Wielder"
const ALIAS = "Arvok"
const SPRITES_POS_VECTOR = Vector2i(7, 2)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillSilentAgony.NAME),
		SkillBase.get_new_learned_skill(SkillBurningPresence.NAME),
	])