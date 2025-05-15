extends Node2D

const ENEMIES_WAVES_CONTROLLER = preload("res://scripts/controllers/enemies_waves_controller.gd")
const MOOMOO_SCENE = preload("res://scenes/entity/moomoo_scene.tscn")

var _enemies_nodes: Node2D
var enemies: Dictionary[int, Enemy] = {}
var players: Dictionary[int, Player] = {}
var moomoo_node
var moomoo: Moomoo

func _ready() -> void:
	print("GameManager ready")
	_set_screen_size()
	_enemies_nodes = get_tree().get_root().get_node("Game/Enemies")
	moomoo_node = get_tree().get_root().get_node("Game/Moomoo")

	moomoo = MOOMOO_SCENE.instantiate()
	moomoo.global_position = Vector2(32 * 20 + 16, 32 * 11 + 16)
	moomoo_node.add_child(moomoo)

	AStarGridManager.set_cell_blocked_from_world(moomoo.global_position, true)

func _set_screen_size() -> void:
	# Obtener tamaño del monitor principal (monitor 0)
	var screen_size = DisplayServer.screen_get_size(0)

	# Calcular nuevo tamaño: 50% del ancho, manteniendo aspecto 16:9 (648p aprox)
	var new_width = int(screen_size.x * 0.4)
	var new_height = int(new_width * 9.0 / 16.0) # mantener aspecto

	DisplayServer.window_set_size(Vector2i(new_width, new_height))

	# Posicionar abajo a la derecha
	var pos_x = screen_size.x - new_width
	var pos_y = screen_size.y - new_height
	DisplayServer.window_set_position(Vector2i(pos_x, pos_y))

func _on_host_game_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	
	# ENEMIES_WAVES_CONTROLLER.start_wave(1)
	
func _on_join_as_player_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_client()

func add_enemy(enemy: Enemy) -> void:
	_enemies_nodes.add_child(enemy)
	enemies[enemy.id] = enemy

func get_entities() -> Array[Entity]:
	return cast_array_to_entity(get_players()) + cast_array_to_entity(get_enemies())

func get_enemies() -> Array[Enemy]:
	return enemies.values()

func get_players() -> Array[Player]:
	return players.values()

func cast_array_to_entity(arr: Array) -> Array[Entity]:
	var result: Array[Entity] = []
	for i in arr:
		result.append(i as Entity)
	return result
