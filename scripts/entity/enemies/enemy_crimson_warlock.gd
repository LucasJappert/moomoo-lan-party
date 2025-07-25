class_name EnemyCrimsonWarlock

extends EnemyBase

const LONG_NAME = "Crimson Warlock"
const ALIAS = "Shiv"
const SPRITES_POS_VECTOR = Vector2i(1, 2)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.set_attack_speed(1.2)
	_enemy.combat_stats.set_evasion(0.2)
	_enemy.combat_stats.set_attack_range(260)
	_enemy.projectile_type = ProjectileDemonBolt.NAME
	
	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillPainEcho.NAME),
		SkillBase.get_new_learned_skill(SkillInfernalTouch.NAME),
	])