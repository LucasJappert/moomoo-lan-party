class_name EnemySilentShuriken

extends EnemyBase

const LONG_NAME = "Silent Shuriken"
const ALIAS = "Shuriken"
const SPRITES_POS_VECTOR = Vector2i(5, 3)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.projectile_type = ProjectileShuriken.NAME
	_enemy.combat_stats.set_crit_chance(0.5)
	_enemy.combat_stats.set_crit_multiplier(2.5)
	
	_enemy.combat_stats.set_attack_range(160)

	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillLifesteal.NAME),
		SkillBase.get_new_learned_skill(SkillFrenziedSilence.NAME),
		null,
		SkillBase.get_new_learned_skill(SkillUnbreakable.NAME),
	])
	_enemy.update_item(Item.get_item(ItemSkeletonSummonersRing.NAME, 1, true), 0)