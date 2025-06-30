class_name EnemyFactory

static func get_enemy_instance(_enemy_type: String = "") -> Enemy:
	var enemy: Enemy = load("res://scenes/entity/enemy_scene.tscn").instantiate()
	if _enemy_type.is_empty(): return enemy

	enemy.set_enemy_type(_enemy_type)
	enemy.combat_stats.initialize_default_values()
	EnemyTypes.initialize(enemy)
	if _enemy_type == EnemyTypes.Names.FROST_REVENANT: set_frost_revenant(enemy)
	if _enemy_type == EnemyTypes.Names.FLAME_CULTIST: set_flame_cultist(enemy)
	if _enemy_type == EnemyTypes.Names.WARDEN_OF_DECAY: set_warden_of_decay(enemy)
	return enemy

# region INTERNAL METHODS
static func set_frost_revenant(_enemy: Enemy):
	if _enemy.extra_info.key_type != EnemyTypes.Names.FROST_REVENANT: return false

	# _enemy.combat_stats.evasion = 0.15
	# _enemy.combat_stats.crit_chance = 0.2

	# _enemy._skills.append_array([Skill.get_new_learned_skill(Skill.Names.FROZEN_TOUCH)])

	return true

static func set_flame_cultist(_enemy: Enemy):
	if _enemy.extra_info.key_type != EnemyTypes.Names.FLAME_CULTIST: return false

	_enemy.attack_type = AttackTypes.RANGED
	_enemy.projectile_type = Projectile.TYPES.FIREBALL
	_enemy.combat_stats.crit_chance = 0.2
	_enemy.combat_stats.crit_multiplier = 1.5
	_enemy.combat_stats.attack_range = 200
	_enemy.combat_stats.physical_attack_power = 1
	_enemy.combat_stats.attack_speed = 1
	
	_enemy._skills.append_array([
		Skill.get_new_learned_skill(Skill.Names.STORM_STRIKE)
	])

static func set_warden_of_decay(_enemy: Enemy):
	if _enemy.extra_info.key_type != EnemyTypes.Names.WARDEN_OF_DECAY: return false

	_enemy.combat_stats.crit_chance = 0.1
	_enemy.combat_stats.crit_multiplier = 1.5

	# _enemy._skills.append_array([Skill.get_new_learned_skill(Skill.Names.MIRROR_DEMISE)])

	return true

# endregion
