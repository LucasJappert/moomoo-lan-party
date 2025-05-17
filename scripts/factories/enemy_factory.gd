class_name EnemyFactory

const ENEMY_SCENE = preload("res://scenes/entity/enemy_scene.tscn")


static func get_enemy_instance(_enemy_type: String) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()

	enemy.set_enemy_type(_enemy_type)

	return enemy


static func set_goblin(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.GOBLIN:
		return false

	_enemy.combat_data.max_hp = 100
	_enemy.combat_data.physical_defense = 5
	_enemy.combat_data.magic_defense = 2
	_enemy.combat_data.evasion = 0.05
	_enemy.combat_data.crit_chance = 0.1
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_speed = 1.2
	_enemy.combat_data.attack_range = 0
	_enemy.combat_data.attack_type = AttackTypes.MELEE

	return true

static func set_skeleton_archer(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.SKELETON_ARCHER:
		return false

	_enemy.combat_data.max_hp = 80
	_enemy.combat_data.physical_defense = 2
	_enemy.combat_data.magic_defense = 1
	_enemy.combat_data.evasion = 0.1
	_enemy.combat_data.crit_chance = 0.15
	_enemy.combat_data.crit_multiplier = 2.0
	_enemy.combat_data.attack_speed = 1.0
	_enemy.combat_data.attack_range = 200
	_enemy.combat_data.attack_type = AttackTypes.RANGED
	_enemy.combat_data.projectile_type = ProjectileTypes.ARROW

	return true

static func set_orc(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.ORC:
		return false

	_enemy.combat_data.max_hp = 100
	_enemy.combat_data.physical_defense = 5
	_enemy.combat_data.magic_defense = 2
	_enemy.combat_data.evasion = 0.05
	_enemy.combat_data.crit_chance = 0.1
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_speed = 1.2
	_enemy.combat_data.attack_range = 0
	_enemy.combat_data.attack_type = AttackTypes.MELEE
	_enemy.combat_data.skills.append(Skill.get_stun_charge())

	return true

static func set_fire_mage(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.FIRE_MAGE:
		return false

	_enemy.combat_data.max_hp = 80
	_enemy.combat_data.physical_defense = 2
	_enemy.combat_data.magic_defense = 1
	_enemy.combat_data.evasion = 0.1
	_enemy.combat_data.crit_chance = 0.15
	_enemy.combat_data.crit_multiplier = 2.0
	_enemy.combat_data.attack_speed = 1.0
	_enemy.combat_data.attack_range = 200
	_enemy.combat_data.attack_type = AttackTypes.RANGED
	_enemy.combat_data.projectile_type = ProjectileTypes.FIREBALL
	_enemy.combat_data.skills.append(Skill.get_fireball())

	return true

static func set_ice_golem(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.ICE_GOLEM:
		return false

	_enemy.combat_data.max_hp = 100
	_enemy.combat_data.physical_defense = 5
	_enemy.combat_data.magic_defense = 2
	_enemy.combat_data.evasion = 0.05
	_enemy.combat_data.crit_chance = 0.1
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_speed = 1.2
	_enemy.combat_data.attack_range = 0
	_enemy.combat_data.attack_type = AttackTypes.MELEE
	_enemy.combat_data.projectile_type = ProjectileTypes.ICE_BOLT
	_enemy.combat_data.skills = [Skill.get_frost_slam()]

	return true

static func set_bat(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.BAT:
		return false

	_enemy.combat_data.max_hp = 80
	_enemy.combat_data.physical_defense = 2
	_enemy.combat_data.magic_defense = 1
	_enemy.combat_data.evasion = 0.1
	_enemy.combat_data.crit_chance = 0.15
	_enemy.combat_data.crit_multiplier = 2.0
	_enemy.combat_data.attack_speed = 1.0
	_enemy.combat_data.attack_range = 50
	_enemy.combat_data.attack_type = AttackTypes.MELEE
	_enemy.combat_data.skills = []

	return true

static func set_dark_priest(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.DARK_PRIEST:
		return false

	_enemy.combat_data.max_hp = 100
	_enemy.combat_data.physical_defense = 5
	_enemy.combat_data.magic_defense = 2
	_enemy.combat_data.evasion = 0.05
	_enemy.combat_data.crit_chance = 0.1
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_speed = 1.2
	_enemy.combat_data.attack_range = 260
	_enemy.combat_data.attack_type = AttackTypes.MAGIC
	_enemy.combat_data.projectile_type = ProjectileTypes.DARK_BOLT
	_enemy.combat_data.skills = [Skill.get_drain_life()]

	return true
	
static func set_slime(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.SLIME:
		return false

	_enemy.combat_data.max_hp = 120
	_enemy.combat_data.physical_defense = 4
	_enemy.combat_data.magic_defense = 4
	_enemy.combat_data.evasion = 0.1
	_enemy.combat_data.crit_chance = 0.05
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_speed = 1.0
	_enemy.combat_data.attack_range = 0
	_enemy.combat_data.attack_type = AttackTypes.MELEE
	_enemy.combat_data.skills = []

	return true

static func set_ghost(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.GHOST:
		return false

	_enemy.combat_data.max_hp = 80
	_enemy.combat_data.physical_defense = 0
	_enemy.combat_data.magic_defense = 6
	_enemy.combat_data.evasion = 0.25
	_enemy.combat_data.crit_chance = 0.15
	_enemy.combat_data.crit_multiplier = 2.0
	_enemy.combat_data.attack_speed = 1.1
	_enemy.combat_data.attack_range = 280
	_enemy.combat_data.attack_type = AttackTypes.MAGIC
	_enemy.combat_data.projectile_type = ProjectileTypes.DARK_BOLT
	_enemy.combat_data.skills = [Skill.get_phase_shift()]

	return true

static func set_exploder(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.EXPLODER:
		return false

	_enemy.combat_data.max_hp = 50
	_enemy.combat_data.physical_defense = 1
	_enemy.combat_data.magic_defense = 1
	_enemy.combat_data.evasion = 0.0
	_enemy.combat_data.crit_chance = 0.0
	_enemy.combat_data.crit_multiplier = 1.0
	_enemy.combat_data.attack_speed = 0.5
	_enemy.combat_data.attack_range = 0
	_enemy.combat_data.attack_type = AttackTypes.MELEE
	_enemy.combat_data.skills = [Skill.get_self_destruct()]

	return true

static func set_combat_data_by_enemy_type(_enemy: Enemy):
	match _enemy.enemy_type:
		EnemyTypes.GOBLIN:
			set_goblin(_enemy)
		EnemyTypes.SKELETON_ARCHER:
			set_skeleton_archer(_enemy)
		EnemyTypes.ORC:
			set_orc(_enemy)
		EnemyTypes.FIRE_MAGE:
			set_fire_mage(_enemy)
		EnemyTypes.ICE_GOLEM:
			set_ice_golem(_enemy)
		EnemyTypes.BAT:
			set_bat(_enemy)
		EnemyTypes.DARK_PRIEST:
			set_dark_priest(_enemy)
		EnemyTypes.SLIME:
			set_slime(_enemy)
		EnemyTypes.GHOST:
			set_ghost(_enemy)
		EnemyTypes.EXPLODER:
			set_exploder(_enemy)
		_:
			print("Unknown enemy type: " + _enemy.enemy_type)
			return false

	return true
