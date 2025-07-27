class_name EnemyFrostboneArcher

extends EnemyBase

const LONG_NAME = "Frostbone Archer" # (Arquero Huesohelado)
const ALIAS = "Frostbite"
const SPRITES_POS_VECTOR = Vector2i(2, 1)


static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.set_attack_range(220)
	_enemy.projectile_type = ProjectileArrow.NAME

	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillFrozenTouch.NAME),
		SkillBase.get_new_learned_skill(SkillBlessingOfPower.NAME),
	])