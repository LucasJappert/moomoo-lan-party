class_name EnemyEmberFiend

extends EnemyBase

const LONG_NAME = "Ember Fiend"
const ALIAS = "Cindral"
const SPRITES_POS_VECTOR = Vector2i(4, 0)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.set_attack_speed(0.3)
	_enemy.combat_stats.set_attack_range(220)
	_enemy.projectile_type = ProjectileFireArrow.NAME
	# _enemy.combat_stats.set_stun_chance(1, 3)
	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillLifesteal.NAME),
		SkillBase.get_new_learned_skill(SkillTrueStrike.NAME),
		SkillBase.get_new_learned_skill(SkillInfernalTouch.NAME),
	])