class_name EnemyNightArcher

extends EnemyBase

const LONG_NAME = "Night Archer"
const ALIAS = "Shadebolt"
const SPRITES_POS_VECTOR = Vector2i(4, 1)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.agility = 21
	_enemy.combat_stats.strength = 16
	_enemy.combat_stats.intelligence = 10
	_enemy.combat_stats.attack_range = 220
	_enemy.projectile_type = ProjectileArrow.NAME

	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillManaScorcher.NAME),
		SkillBase.get_new_learned_skill(SkillFrenziedSilence.NAME),
	])