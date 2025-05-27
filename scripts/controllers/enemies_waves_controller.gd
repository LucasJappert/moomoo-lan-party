class_name EnemiesWavesController

static var _wave_number: int = 0

static func start_wave() -> void:
	_wave_number += 1
	print("Wave " + str(_wave_number) + " started!")

	const TILES_DISTANCE = 9
	const ENEMIES_BY_ZONE = 6
	var counter = 0
	var moomoo_position = GameManager.moomoo.global_position

	const possible_enemies = [
		# EnemyTypes.FROST_REVENANT,
		# EnemyTypes.WARDEN_OF_DECAY,
		EnemyTypes.FLAME_CULTIST
	]
	for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		for i in range(ENEMIES_BY_ZONE):
			counter += 1
			var enemy: Enemy = EnemyFactory.get_enemy_instance(possible_enemies[randi() % possible_enemies.size()])
			var random_noise = Vector2(randi_range(-64, 64), randi_range(-64, 64))
			enemy.global_position = moomoo_position + direction * TILES_DISTANCE * 64 + random_noise
			enemy.id = counter
			
			if i == ENEMIES_BY_ZONE - 1:
				enemy._boss_level = _wave_number # Add a boss
			else:
				enemy.combat_data.skills.clear()
				
			GameManager.add_enemy(enemy)
