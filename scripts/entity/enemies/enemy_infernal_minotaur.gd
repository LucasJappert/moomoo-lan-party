class_name EnemyInfernalMinotaur

extends EnemyBase

const LONG_NAME = "Infernal Minotaur"
const ALIAS = "Threx"
const SPRITES_POS_VECTOR = Vector2i(3, 2)

static func try_to_init_from_name(_name: String, _enemy: Enemy) -> void:
	if _name != LONG_NAME: return
	
	_enemy.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(SPRITES_POS_VECTOR), ALIAS)

	_enemy.combat_stats.agility = 21
	_enemy.combat_stats.strength = 16
	_enemy.combat_stats.intelligence = 10

	_enemy.combat_stats.crit_chance = 0.2
	_enemy.combat_stats.crit_multiplier = 1.5

	_enemy._skills.append_array([
		Skill.get_new_learned_skill(Skill.Names.BLOOD_FURY),
		Skill.get_new_learned_skill(SkillLifesteal.NAME),
	])