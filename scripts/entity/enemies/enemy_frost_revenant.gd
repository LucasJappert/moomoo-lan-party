class_name EnemyFrostRevenant

extends EnemyBase

const LONG_NAME = "Frost Revenant"
const ALIAS = "Frostreign"
const SPRITES_POS_VECTOR = Vector2i(0, 0)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.set_crit_chance(0.3)
	_enemy.combat_stats.set_crit_multiplier(2.5)
	
	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillFrozenTouch.NAME),
		SkillBase.get_new_learned_skill(SkillAbsorbAndRelease.NAME),
	])