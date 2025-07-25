class_name EnemyRotbull

extends EnemyBase

const LONG_NAME = "Rotbull"
const ALIAS = "Rotbull"
const SPRITES_POS_VECTOR = Vector2i(5, 1)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.set_crit_chance(0.2)
	_enemy.combat_stats.set_crit_multiplier(2)
	_enemy.combat_stats.set_attack_range(240)
	_enemy.projectile_type = ProjectileVenomArrow.NAME

	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillMirrorDemise.NAME),
		SkillBase.get_new_learned_skill(SkillInfernalTouch.NAME),
	])