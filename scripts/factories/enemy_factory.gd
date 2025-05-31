class_name EnemyFactory

const ENEMY_SCENE = preload("res://scenes/entity/enemy_scene.tscn")


static func get_enemy_instance(_enemy_type: String) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()

	enemy.set_enemy_type(_enemy_type)

	return enemy

# region INTERNAL METHODS
static func set_frost_revenant(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.FROST_REVENANT: return false

	_enemy.combat_data.max_hp = 100
	_enemy.combat_data.evasion = 0.15
	_enemy.combat_data.crit_chance = 0.2

	_enemy.combat_data.skills.append_array([Skill.get_mirror_demise()])

	return true

static func set_warden_of_decay(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.WARDEN_OF_DECAY: return false

	_enemy.combat_data.max_hp = 120
	_enemy.combat_data.crit_chance = 0.1
	_enemy.combat_data.crit_multiplier = 1.5

	_enemy.combat_data.skills.append_array([Skill.get_mirror_demise()])

	return true

static func set_flame_cultist(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.FLAME_CULTIST: return false

	_enemy.combat_data.max_hp = 1010
	_enemy.combat_data.crit_chance = 0.2
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_range = 200
	_enemy.combat_data.attack_type = AttackTypes.RANGED
	_enemy.combat_data.projectile_type = Projectile.TYPES.FIREBALL

	_enemy.combat_data.skills.append_array([
		# Skill.get_mirror_demise(),
		# Skill.get_frozen_touch(),
		# Skill.get_stunning_strike(),
	])

# endregion
