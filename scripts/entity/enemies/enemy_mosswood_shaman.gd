class_name EnemyMosswoodShaman

extends EnemyBase

const LONG_NAME = "Mosswood Shaman"
const ALIAS = "Mossgrove"
const SPRITES_POS_VECTOR = Vector2i(3, 0)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.set_attack_range(220)
	_enemy.projectile_type = ProjectileNatureBall.NAME

	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillShieldedCore.NAME),
		SkillBase.get_new_learned_skill(SkillShockSpear.NAME),
	])