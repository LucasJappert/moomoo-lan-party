extends Node2D

const ENEMIES_WAVES_CONTROLLER = preload("res://scripts/controllers/enemies_waves_controller.gd")

var enemies_node # Just for the server
var players: Dictionary[int, Player] = {}
var moomoo: Moomoo

func _ready() -> void:
	_set_screen_size()
	enemies_node = get_tree().get_root().get_node("Game/Enemies")
	moomoo = get_tree().get_root().get_node("Game/Moomoo")

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
	
	ENEMIES_WAVES_CONTROLLER.start_wave(1)
	
func _on_join_as_player_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_client()
