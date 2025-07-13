class_name EnemyCinderflameWielder

extends EnemyBase

const LONG_NAME = "Cinderflame Wielder"
const ALIAS = "Arvok"
const SPRITES_POS_VECTOR = Vector2i(7, 2)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.agility = 5
	_enemy.combat_stats.strength = 10
	_enemy.combat_stats.intelligence = 15

	_enemy._skills.append_array([
		Skill.get_new_learned_skill(SkillBurningPresence.NAME),
	])