class_name EnemySilentShuriken

extends EnemyBase

const LONG_NAME = "Silent Shuriken"
const ALIAS = "Shuriken"
const SPRITES_POS_VECTOR = Vector2i(5, 3)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.projectile_type = ProjectileShuriken.NAME
	_enemy.combat_stats.crit_chance = 0.5
	_enemy.combat_stats.crit_multiplier = 2.5
	
	_enemy.combat_stats.attack_range = 160

	_enemy._skills.append_array([
		Skill.get_new_learned_skill(SkillLifesteal.NAME),
		Skill.get_new_learned_skill(Skill.Names.FRENZIED_SILENCE),
		null,
		Skill.get_new_learned_skill(SkillUnbreakable.NAME),
	])