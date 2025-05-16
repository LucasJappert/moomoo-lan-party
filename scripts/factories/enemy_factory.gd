class_name EnemyFactory

const ENEMY_SCENE = preload("res://scenes/entity/enemy_scene.tscn")

static func get_goblin() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.GOBLIN)
	enemy.combat_data.max_hp = 100
	enemy.combat_data.physical_defense = 5
	enemy.combat_data.magic_defense = 2
	enemy.combat_data.evasion = 0.05
	enemy.combat_data.crit_chance = 0.1
	enemy.combat_data.crit_multiplier = 1.5
	enemy.combat_data.attack_speed = 1.2
	enemy.combat_data.attack_range = 0
	enemy.combat_data.attack_type = AttackTypes.MELEE
	return enemy

static func get_skeleton_archer() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.SKELETON_ARCHER)
	enemy.combat_data.max_hp = 80
	enemy.combat_data.physical_defense = 2
	enemy.combat_data.magic_defense = 1
	enemy.combat_data.evasion = 0.1
	enemy.combat_data.crit_chance = 0.15
	enemy.combat_data.crit_multiplier = 2.0
	enemy.combat_data.attack_speed = 1.0
	enemy.combat_data.attack_range = 300
	enemy.combat_data.attack_type = AttackTypes.RANGED
	enemy.combat_data.projectile_type = ProjectileTypes.ARROW
	return enemy

static func get_orc() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.ORC)
	enemy.combat_data.max_hp = 100
	enemy.combat_data.physical_defense = 5
	enemy.combat_data.magic_defense = 2
	enemy.combat_data.evasion = 0.05
	enemy.combat_data.crit_chance = 0.1
	enemy.combat_data.crit_multiplier = 1.5
	enemy.combat_data.attack_speed = 1.2
	enemy.combat_data.attack_range = 0
	enemy.combat_data.attack_type = AttackTypes.MELEE
	enemy.combat_data.skills.append(Skill.get_stun_charge())
	return enemy

static func get_fire_mage() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.FIRE_MAGE)
	enemy.combat_data.max_hp = 80
	enemy.combat_data.physical_defense = 2
	enemy.combat_data.magic_defense = 1
	enemy.combat_data.evasion = 0.1
	enemy.combat_data.crit_chance = 0.15
	enemy.combat_data.crit_multiplier = 2.0
	enemy.combat_data.attack_speed = 1.0
	enemy.combat_data.attack_range = 300
	enemy.combat_data.attack_type = AttackTypes.RANGED
	enemy.combat_data.projectile_type = ProjectileTypes.FIREBALL
	enemy.combat_data.skills.append(Skill.get_fireball())
	return enemy

static func get_ice_golem() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.ICE_GOLEM)
	enemy.combat_data.max_hp = 100
	enemy.combat_data.physical_defense = 5
	enemy.combat_data.magic_defense = 2
	enemy.combat_data.evasion = 0.05
	enemy.combat_data.crit_chance = 0.1
	enemy.combat_data.crit_multiplier = 1.5
	enemy.combat_data.attack_speed = 1.2
	enemy.combat_data.attack_range = 0
	enemy.combat_data.attack_type = AttackTypes.MELEE
	enemy.combat_data.projectile_type = ProjectileTypes.ICE_BOLT
	enemy.combat_data.skills = [Skill.get_frost_slam()]
	return enemy

static func get_bat() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.BAT)
	enemy.combat_data.max_hp = 80
	enemy.combat_data.physical_defense = 2
	enemy.combat_data.magic_defense = 1
	enemy.combat_data.evasion = 0.1
	enemy.combat_data.crit_chance = 0.15
	enemy.combat_data.crit_multiplier = 2.0
	enemy.combat_data.attack_speed = 1.0
	enemy.combat_data.attack_range = 50
	enemy.combat_data.attack_type = AttackTypes.MELEE
	enemy.combat_data.skills = []
	return enemy

static func get_dark_priest() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.DARK_PRIEST)
	enemy.combat_data.max_hp = 100
	enemy.combat_data.physical_defense = 5
	enemy.combat_data.magic_defense = 2
	enemy.combat_data.evasion = 0.05
	enemy.combat_data.crit_chance = 0.1
	enemy.combat_data.crit_multiplier = 1.5
	enemy.combat_data.attack_speed = 1.2
	enemy.combat_data.attack_range = 400
	enemy.combat_data.attack_type = AttackTypes.MAGIC
	enemy.combat_data.projectile_type = ProjectileTypes.DARK_BOLT
	enemy.combat_data.skills = [Skill.get_drain_life()]
	return enemy
	
static func get_slime() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.SLIME)
	enemy.combat_data.max_hp = 120
	enemy.combat_data.physical_defense = 4
	enemy.combat_data.magic_defense = 4
	enemy.combat_data.evasion = 0.1
	enemy.combat_data.crit_chance = 0.05
	enemy.combat_data.crit_multiplier = 1.5
	enemy.combat_data.attack_speed = 1.0
	enemy.combat_data.attack_range = 0
	enemy.combat_data.attack_type = AttackTypes.MELEE
	enemy.combat_data.skills = []
	return enemy

static func get_ghost() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.GHOST)
	enemy.combat_data.max_hp = 80
	enemy.combat_data.physical_defense = 0
	enemy.combat_data.magic_defense = 6
	enemy.combat_data.evasion = 0.25
	enemy.combat_data.crit_chance = 0.15
	enemy.combat_data.crit_multiplier = 2.0
	enemy.combat_data.attack_speed = 1.1
	enemy.combat_data.attack_range = 280
	enemy.combat_data.attack_type = AttackTypes.MAGIC
	enemy.combat_data.projectile_type = ProjectileTypes.DARK_BOLT
	enemy.combat_data.skills = [Skill.get_phase_shift()]
	return enemy

static func get_exploder() -> Enemy:
	var enemy := Enemy.get_instance(EnemyTypes.EXPLODER)
	enemy.combat_data.max_hp = 50
	enemy.combat_data.physical_defense = 1
	enemy.combat_data.magic_defense = 1
	enemy.combat_data.evasion = 0.0
	enemy.combat_data.crit_chance = 0.0
	enemy.combat_data.crit_multiplier = 1.0
	enemy.combat_data.attack_speed = 0.5
	enemy.combat_data.attack_range = 0
	enemy.combat_data.attack_type = AttackTypes.MELEE
	enemy.combat_data.skills = [Skill.get_self_destruct()]
	return enemy

static func get_enemy_by_type(type: String) -> Enemy:
	match type:
		EnemyTypes.GOBLIN:
			return get_goblin()
		EnemyTypes.SKELETON_ARCHER:
			return get_skeleton_archer()
		EnemyTypes.ORC:
			return get_orc()
		EnemyTypes.FIRE_MAGE:
			return get_fire_mage()
		EnemyTypes.ICE_GOLEM:
			return get_ice_golem()
		EnemyTypes.BAT:
			return get_bat()
		EnemyTypes.DARK_PRIEST:
			return get_dark_priest()
		EnemyTypes.SLIME:
			return get_slime()
		EnemyTypes.GHOST:
			return get_ghost()
		EnemyTypes.EXPLODER:
			return get_exploder()
	return null
