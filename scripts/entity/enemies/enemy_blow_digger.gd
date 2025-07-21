class_name EnemyBlowDigger

extends EnemyBase

const LONG_NAME = "Blow Digger"
const ALIAS = "Digger"
const SPRITES_POS_VECTOR = Vector2i(1, 3)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.stun_chance = 0.1
	_enemy.combat_stats.stun_duration = 1
	
	_enemy._skills.append_array([
		Skill.get_new_learned_skill(SkillDeathBurst.NAME),
	])