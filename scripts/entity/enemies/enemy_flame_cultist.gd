class_name EnemyFlameCultist

extends EnemyBase

const LONG_NAME = "Flame Cultist"
const ALIAS = "Pyraeth"
const SPRITES_POS_VECTOR = Vector2i(2, 0)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.projectile_type = ProjectileArcLightning.NAME
	_enemy.combat_stats.crit_chance = 0.1
	_enemy.combat_stats.crit_multiplier = 1.5
	_enemy.combat_stats.attack_range = 200
	_enemy.combat_stats.physical_attack_power = 1
	_enemy._skills.append_array([
		Skill.get_new_learned_skill(SkillStormStrike.NAME),
	])