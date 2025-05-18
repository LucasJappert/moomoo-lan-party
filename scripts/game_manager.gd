extends Node2D

const ENEMIES_WAVES_CONTROLLER = preload("res://scripts/controllers/enemies_waves_controller.gd")
const MOOMOO_SCENE = preload("res://scenes/entity/moomoo_scene.tscn")
const PLAYER_SCENE = preload("res://scenes/entity/player_scene.tscn")

@onready var player_spawner = $PlayerSpawner

func _ready() -> void:
	MyCamera.set_screen_size()

	call_deferred("_init_player_spawner")
	GameManager.enemies_node = $Enemies
	GameManager.players_node = $Players
	GameManager.moomoo_node = $Moomoo
	GameManager.projectiles_node = $Projectiles

	GameManager.moomoo = MOOMOO_SCENE.instantiate()
	GameManager.moomoo_node.add_child(GameManager.moomoo)
	AStarGridManager.set_cell_blocked_from_world(GameManager.moomoo.global_position, true)

func _init_player_spawner():
	player_spawner.spawn_function = Callable(self, "_spawn_custom")

func _spawn_custom(data: Dictionary) -> Node:
	var player = PLAYER_SCENE.instantiate()
	var player_id: int = data["player_id"]
	player.set_player_id(player_id)
	player.get_client_inputs().set_multiplayer_authority(player_id)
	return player


func _on_host_game_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	
	ENEMIES_WAVES_CONTROLLER.start_wave(1)
	
func _on_join_as_player_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_client()
