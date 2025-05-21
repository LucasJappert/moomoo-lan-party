extends Node2D

const ENEMIES_WAVES_CONTROLLER = preload("res://scripts/controllers/enemies_waves_controller.gd")
const MOOMOO_SCENE = preload("res://scenes/entity/moomoo_scene.tscn")
const PLAYER_SCENE = preload("res://scenes/entity/player_scene.tscn")

@onready var player_spawner = $PlayerSpawner
@onready var terrain = $Terrain

func _ready() -> void:
	MapManager.initialize()

	MyCamera.set_screen_size()
	%MultiplayerHUD.show()

	call_deferred("_init_player_spawner")

	MyTree.spawn_trees()

	DecorationsFactory.add_random_decorations_over_grass_terrain()
	DecorationsFactory.add_random_decorations_over_dirt_terrain()

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
	_spawn_moomoo()
	
	ENEMIES_WAVES_CONTROLLER.start_wave(1)
	
func _on_join_as_player_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_client()
	_spawn_moomoo()


func _spawn_moomoo() -> void:
	GameManager.moomoo = MOOMOO_SCENE.instantiate()
	GameManager.moomoo_node.add_child(GameManager.moomoo, true)
	MapManager.set_cell_blocked_from_world(GameManager.moomoo.global_position, true)
