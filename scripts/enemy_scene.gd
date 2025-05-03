class_name Enemy

extends CharacterBody2D

static var enemy_scene = preload("res://scenes/enemy_scene.tscn")

func _ready():
	collision_layer = 1
	collision_mask = 1

static func spawn_enemy(moomoo_position = Vector2.ZERO):
	var TILES_DISTANCE = 10
	var ENEMIES_BY_ZONE = 4

	for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		for i in range(ENEMIES_BY_ZONE):
			var enemy = enemy_scene.instantiate()
			var random_noise = Vector2(randi_range(-64, 64), randi_range(-64, 64))
			enemy.position = moomoo_position + direction * TILES_DISTANCE * 64 + random_noise
			GameManager.enemies_node.add_child(enemy)


# agregar estatua al centro
# hacer que los enemigos se muevan hacia el centro
