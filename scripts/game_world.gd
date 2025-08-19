class_name GameWorld

extends Node2D

static var SCREEN_SIZE: Vector2 = Vector2.ZERO
@onready var gui_scene: GUIScene = $GuiScene
@onready var player_spawner = $PlayerSpawner
@onready var projectiles_spawner = $ProjectilesSpawner
@onready var enemies_spawner = $EnemiesSpawner
@onready var moomoo_spawner = $MoomooSpawner
@onready var general_container = %GeneralContainer
@onready var over_terrain_layer_layer_1: Node2D = %OverTerrainLayerLayer1
@onready var over_terrain_layer_layer_2: Node2D = %OverTerrainLayerLayer2
var ambient_sounds_helper: AmbientSoundsHelper = AmbientSoundsHelper.new()

@onready var my_trees_node: Node2D = $MyTrees
@onready var terrain: Node2D = $Terrain
@onready var decorations_node: Node2D = $Terrain/Decorations

static var current_enemies_in_scene = 0
const HOSTED_GAME = true # In this version of Moomoo this is always true


static func load_scene() -> void:
	var scene = load("res://scenes/game_world_scene.tscn").instantiate()
	GameManager.game_world = scene
	MainScene.load_scene(scene)
	MainScene.total_paused_time = 0

func _ready() -> void:
	current_enemies_in_scene = 0
	# DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
	MapManager.initialize()

	call_deferred("_init_player_spawner")
	call_deferred("_init_moomoo_spawner")
	call_deferred("_init_enemies_spawner")
	call_deferred("_init_projectiles_spawner")
	call_deferred("_spawn_player_moomoo_and_enemies")

	MyTree.spawn_trees()

	DecorationsFactory.add_random_decorations_over_grass_terrain()
	DecorationsFactory.add_random_decorations_over_dirt_terrain()

	DamagePopupPool.preload_popups()
	NightAmbienceHelper.start(get_tree())

func _exit_tree() -> void:
	over_terrain_layer_layer_1.queue_free()
	over_terrain_layer_layer_2.queue_free()
	print("EXITING GAME WORLD")

func _process(_delta: float) -> void:
	MapManager.GLOBAL_MOUSE_POSITION = get_global_mouse_position()
	MapManager.VIEWPORT_MOUSE_POSITION = get_viewport().get_mouse_position()
	ambient_sounds_helper.update_fire_sound()
	SCREEN_SIZE = get_viewport().get_visible_rect().size

func _spawn_player_moomoo_and_enemies() -> void:
	GameManager.spawn_player(HeroPickerScene.hero_picked_type)
	GameManager.spawn_moomoo()
	EnemiesWavesController.start_wave_process()

func _init_player_spawner():
	player_spawner.spawn_function = Callable(self, "_spawn_custom_player")
func _spawn_custom_player(data: Dictionary) -> Node:
	var player = load("res://scenes/entity/player_scene.tscn").instantiate()
	player.set_player(data)
	player.set_current_hp_and_mana()
	player.get_client_inputs().set_multiplayer_authority(player.player_id)
	return player
	
func _init_moomoo_spawner():
	moomoo_spawner.spawn_function = Callable(self, "_spawn_custom_moomoo")
func _spawn_custom_moomoo(_data: Dictionary) -> Node:
	return Moomoo.get_new_instance()

func _init_enemies_spawner():
	enemies_spawner.spawn_function = Callable(self, "_spawn_custom_enemy")
func _spawn_custom_enemy(data: Dictionary = {}) -> Node:
	var result = Enemy.get_instance_from_dict(data)
	return result

func _init_projectiles_spawner():
	projectiles_spawner.spawn_function = Callable(self, "_spawn_custom_projectile")
func _spawn_custom_projectile(data: Dictionary = {}) -> Node:
	return Projectile.get_instance_from_dict(data)

# region 	GETTERs
static func get_gui_scene() -> GUIScene: return GameManager.game_world.gui_scene
# endregion GETTERs