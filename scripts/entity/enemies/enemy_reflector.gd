class_name EnemyReflector

extends EnemyBase

const LONG_NAME = "Reflector"
const ALIAS = "Zeek"
const SPRITES_POS_VECTOR = Vector2i(0, 1)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.crit_chance = 0.3
	_enemy.combat_stats.crit_multiplier = 2
	
	_enemy.combat_stats.stun_chance = 0.02
	_enemy.combat_stats.stun_duration = 1
	
	_enemy._skills.append_array([
		SkillBase.get_new_learned_skill(SkillPainEcho.NAME),
	])