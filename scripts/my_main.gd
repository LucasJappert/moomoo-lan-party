class_name MyMain

extends Node2D

static var GLOBAL_MOUSE_POSITION: Vector2 = Vector2.ZERO
static var VIEWPORT_MOUSE_POSITION: Vector2 = Vector2.ZERO
static var SCREEN_SIZE: Vector2 = Vector2.ZERO
@onready var gui_scene: GUIScene = $GuiScene
@onready var hero_picker_scene: HeroPickerScene = $HeroPickerScene
@onready var projectiles_spawner = $ProjectilesSpawner
@onready var enemies_spawner = $EnemiesSpawner
@onready var moomoo_spawner = $MoomooSpawner
@onready var general_container = $GeneralContainer
const HOSTED_GAME = true # In this version of Moomoo this is always true

@onready var player_spawner = $PlayerSpawner
@onready var terrain = $Terrain
@onready var my_tooltip = $MyTooltipContainer/MyTooltip


func _ready() -> void:
	gui_scene.hide()
	# DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
	MapManager.initialize()

	MyCamera.set_screen_size()
	MyCamera.create_camera()

	call_deferred("_init_player_spawner")
	call_deferred("_init_moomoo_spawner")
	call_deferred("_init_enemies_spawner")
	call_deferred("_init_projectiles_spawner")

	MyTree.spawn_trees()

	DecorationsFactory.add_random_decorations_over_grass_terrain()
	DecorationsFactory.add_random_decorations_over_dirt_terrain()

	SoundsHelper.initialize()
	DamagePopupPool.preload_popups()

func _process(_delta: float) -> void:
	GLOBAL_MOUSE_POSITION = get_global_mouse_position()
	VIEWPORT_MOUSE_POSITION = get_viewport().get_mouse_position()
	SCREEN_SIZE = get_viewport().get_visible_rect().size

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
	return Moomoo.get_instance()

func _init_enemies_spawner():
	enemies_spawner.spawn_function = Callable(self, "_spawn_custom_enemy")
func _spawn_custom_enemy(data: Dictionary = {}) -> Node:
	var result = Enemy.get_instance_from_dict(data)
	return result

func _init_projectiles_spawner():
	projectiles_spawner.spawn_function = Callable(self, "_spawn_custom_projectile")
func _spawn_custom_projectile(data: Dictionary = {}) -> Node:
	return Projectile.get_instance_from_dict(data)
