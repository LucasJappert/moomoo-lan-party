class_name MyMain

extends Node2D

const PLAYER_SCENE = preload("res://scenes/entity/player_scene.tscn")

static var GLOBAL_MOUSE_POSITION: Vector2 = Vector2.ZERO
static var VIEWPORT_MOUSE_POSITION: Vector2 = Vector2.ZERO
static var SCREEN_SIZE: Vector2 = Vector2.ZERO
@onready var gui_scene: CanvasLayer = $GuiScene
const HOSTED_GAME = true # In this version of Moomoo this is always true

@onready var player_spawner = $PlayerSpawner
@onready var terrain = $Terrain


func _ready() -> void:
	# DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
	MapManager.initialize()

	MyCamera.set_screen_size()
	MyCamera.create_camera()

	call_deferred("_init_player_spawner")

	MyTree.spawn_trees()

	DecorationsFactory.add_random_decorations_over_grass_terrain()
	DecorationsFactory.add_random_decorations_over_dirt_terrain()

	SoundManager.initialize()
	DamagePopupPool.preload_popups()

func _process(_delta: float) -> void:
	GLOBAL_MOUSE_POSITION = get_global_mouse_position()
	VIEWPORT_MOUSE_POSITION = get_viewport().get_mouse_position()
	SCREEN_SIZE = get_viewport().get_visible_rect().size

func _init_player_spawner():
	player_spawner.spawn_function = Callable(self, "_spawn_custom")

func _spawn_custom(data: Dictionary) -> Node:
	var player = PLAYER_SCENE.instantiate()
	player.set_player(data)
	player.get_client_inputs().set_multiplayer_authority(player.player_id)
	return player
