extends Node2D

const enemy_scene = preload("res://scenes/enemy_scene.tscn")
var enemies_node # Just for the server
var moomoo: Moomoo

func _ready() -> void:
	_set_screen_size()
	enemies_node = get_tree().get_root().get_node("Game/Enemies")
	# _create_random_enemies()
	moomoo = get_tree().get_root().get_node("Game/Moomoo")
	Enemy.spawn_enemy(moomoo.position)

func _set_screen_size() -> void:
	# Obtener tamaño del monitor principal (monitor 0)
	var screen_size = DisplayServer.screen_get_size(0)

	# Calcular nuevo tamaño: 50% del ancho, manteniendo aspecto 16:9 (648p aprox)
	var new_width = int(screen_size.x * 0.4)
	var new_height = int(new_width * 9.0 / 16.0) # mantener aspecto

	DisplayServer.window_set_size(Vector2i(new_width, new_height))

	# (Opcional) Centrar la ventana
	var pos_x = int((screen_size.x - new_width) / 2)
	var pos_y = int((screen_size.y - new_height) / 2)
	DisplayServer.window_set_position(Vector2i(pos_x, pos_y))

func _on_host_game_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	
func _on_join_as_player_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_client()

func _create_random_enemies() -> void:
	for _i in range(10):
		var enemy = enemy_scene.instantiate()
		enemy.position = Vector2(randf_range(0, 1200), randf_range(0, 800))
		enemies_node.add_child(enemy)
