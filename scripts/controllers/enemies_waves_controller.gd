class_name EnemiesWavesController

static func start_wave(wave: int) -> void:
	return
	print("Wave " + str(wave) + " started!")

	const TILES_DISTANCE = 9
	const ENEMIES_BY_ZONE = 6
	var counter = 0
	var moomoo_position = GameManager.moomoo.global_position

	if wave == 1:
		for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			for i in range(ENEMIES_BY_ZONE):
				counter += 1
				var enemy: Enemy = EnemyFactory.get_skeleton_archer()
				var random_noise = Vector2(randi_range(-64, 64), randi_range(-64, 64))
				enemy.global_position = moomoo_position + direction * TILES_DISTANCE * 64 + random_noise
				enemy.id = counter
				GameManager.add_enemy(enemy)