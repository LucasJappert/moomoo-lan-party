class_name EnemyFactory

static func get_enemy_instance(_enemy_type: String) -> Enemy:
	var enemy: Enemy = load("res://scenes/entity/enemy_scene.tscn").instantiate()

	enemy.set_enemy_type(_enemy_type)

	return enemy

# region INTERNAL METHODS
static func set_frost_revenant(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.FROST_REVENANT: return false

	_enemy.combat_data.base_hp = 100
	_enemy.combat_data.evasion = 0.15
	_enemy.combat_data.crit_chance = 0.2

	_enemy.combat_data.skills.append_array([Skill.get_skill(Skill.Names.MIRROR_DEMISE)])

	return true

static func set_warden_of_decay(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.WARDEN_OF_DECAY: return false

	_enemy.combat_data.base_hp = 120
	_enemy.combat_data.crit_chance = 0.1
	_enemy.combat_data.crit_multiplier = 1.5

	_enemy.combat_data.skills.append_array([Skill.get_skill(Skill.Names.MIRROR_DEMISE)])

	return true

static func set_flame_cultist(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.FLAME_CULTIST: return false

	_enemy.combat_data.base_hp = 1010
	_enemy.combat_data.crit_chance = 0.2
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_range = 200
	_enemy.combat_data.attack_type = AttackTypes.RANGED
	_enemy.combat_data.projectile_type = Projectile.TYPES.FIREBALL
	_enemy.combat_data.physical_attack_power = 2
	
	_enemy.combat_data.skills.append_array([
		Skill.get_skill(Skill.Names.LIFESTEAL),
	])

# endregion
