class_name EnemyFactory

const ENEMY_SCENE = preload("res://scenes/entity/enemy_scene.tscn")


static func get_enemy_instance(_enemy_type: String) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()

	enemy.set_enemy_type(_enemy_type)
	set_combat_data_by_enemy_type(enemy)

	return enemy

static func set_combat_data_by_enemy_type(_enemy: Enemy):
	if _enemy.combat_data == null: _enemy.combat_data = CombatData.new()
	
	match _enemy.enemy_type:
		EnemyTypes.FROST_REVENANT:
			_set_frost_revenant(_enemy)
		EnemyTypes.WARDEN_OF_DECAY:
			_set_warden_of_decay(_enemy)
		EnemyTypes.FLAME_CULTIST:
			_set_flame_cultist(_enemy)
		_:
			print("Unknown enemy type: " + _enemy.enemy_type)
			return false

	if _enemy.combat_data.attack_range < CombatData.MIN_ATTACK_RANGE:
		_enemy.combat_data.attack_range = CombatData.MIN_ATTACK_RANGE
	_enemy.combat_data.current_hp = _enemy.combat_data.max_hp
		
	return true

# region INTERNAL METHODS
static func _set_frost_revenant(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.FROST_REVENANT: return false

	_enemy.combat_data.max_hp = 100
	_enemy.combat_data.physical_defense = 5
	_enemy.combat_data.magic_defense = 2
	_enemy.combat_data.evasion = 0.05
	_enemy.combat_data.crit_chance = 0.2
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_speed = 1.2
	_enemy.combat_data.attack_range = 0
	_enemy.combat_data.attack_type = AttackTypes.MELEE

	_enemy.combat_data.skills.append_array([Skill.get_mirror_demise()])

	return true

static func _set_warden_of_decay(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.WARDEN_OF_DECAY: return false

	_enemy.combat_data.max_hp = 120
	_enemy.combat_data.physical_defense = 8
	_enemy.combat_data.magic_defense = 4
	_enemy.combat_data.evasion = 0.1
	_enemy.combat_data.crit_chance = 0.1
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_speed = 1
	_enemy.combat_data.attack_range = 0
	_enemy.combat_data.attack_type = AttackTypes.MELEE

	_enemy.combat_data.skills.append_array([Skill.get_mirror_demise()])

	return true

static func _set_flame_cultist(_enemy: Enemy):
	if _enemy.enemy_type != EnemyTypes.FLAME_CULTIST: return false

	_enemy.combat_data.max_hp = 1000
	_enemy.combat_data.physical_defense = 5
	_enemy.combat_data.magic_defense = 2
	_enemy.combat_data.evasion = 0.05
	_enemy.combat_data.crit_chance = 0.2
	_enemy.combat_data.crit_multiplier = 1.5
	_enemy.combat_data.attack_speed = 1.2
	_enemy.combat_data.attack_range = 0
	_enemy.combat_data.attack_type = AttackTypes.MELEE

	_enemy.combat_data.skills.append_array([Skill.get_mirror_demise()])

# endregion
