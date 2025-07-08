extends Node

var my_main: MyMain
var enemies_node: Node2D
var entities: Dictionary[String, Entity] = {}
var players_node: Node2D
var projectiles_node: Node2D
var moomoo_node
var moomoo: Moomoo
var my_trees_node
var terrain
var audio_node
var MY_PLAYER: Player
var MY_PLAYER_ID: int = -1
var AM_I_HOST = false
var current_enemies_in_scene = 0

func _ready():
	my_main = get_tree().get_root().get_node("MyMain")
	enemies_node = get_tree().root.get_node("MyMain/Enemies")
	players_node = get_tree().root.get_node("MyMain/Players")
	moomoo_node = get_tree().root.get_node("MyMain/Moomoo")
	projectiles_node = get_tree().root.get_node("MyMain/Projectiles")
	my_trees_node = get_tree().root.get_node("MyMain/MyTrees")
	terrain = get_tree().root.get_node("MyMain/Terrain")
	audio_node = get_tree().root.get_node("MyMain/Audio")

func start_game(hero_type: String) -> void:
	my_main.hero_picker_scene.hide()
	my_main.gui_scene.show()
	MultiplayerManager.become_host(hero_type)
	GameManager.spawn_moomoo()
	EnemiesWavesController.start_wave_process()

func _init_projectiles_spawner() -> void:
	my_main.projectiles_spawner.spawn_function = func(data: Dictionary) -> Node:
		return Projectile.get_instance_from_dict(data)

func _process(delta: float) -> void:
	CursorManager._static_process(delta)
	WindowFocusWatcher._process(delta)
	EnemiesWavesController._process(delta)

func add_my_tree(my_tree: MyTree) -> void:
	my_trees_node.add_child(my_tree, true)
	MapManager.set_cell_blocked(MapManager.world_to_cell(my_tree.global_position), true)

func add_entity(entity: Entity) -> void:
	if entity is Enemy:
		current_enemies_in_scene += 1
	entities[entity.name] = entity

	if not AM_I_HOST: return

	var safe_cell = MapManager.get_safe_cell(MapManager.world_to_cell(entity.global_position))
	if safe_cell == null:
		return print("⚠️ No safe cell found for entity: " + entity.name)

	entity.global_position = MapManager.cell_to_world(safe_cell)
	MapManager.set_cell_blocked(safe_cell, true)

func remove_entity(entity: Entity) -> void:
	entities.erase(entity.name)
	_actions_for_server_side_after_entity_removed(entity)

func _actions_for_server_side_after_entity_removed(entity: Entity) -> void:
	if not AM_I_HOST: return
	
	if entity is Enemy:
		current_enemies_in_scene -= 1
		if current_enemies_in_scene == 0: EventBus.emit_wave_finilized()
	
	# var current_cell = MapManager.world_to_cell(entity.movement_helper.current_cell)
	MapManager.set_cell_blocked(entity.movement_helper.next_target_cell, false)
	EventBus.emit_freed_entity(entity.name)
	entity.queue_free() # We shouldn't do this in the client side, server should do it and sync it

func _on_enemy_exited_tree() -> void:
	current_enemies_in_scene -= 1

func get_players() -> Array[Entity]:
	# TODO: Improve with cache by frame
	return entities.values().filter(func(e): return e is Player)

func get_enemies() -> Array[Entity]:
	return entities.values().filter(func(e): return e is Enemy)

func get_moomoo() -> Entity: return moomoo

func get_entity(entity_name: String) -> Entity:
	return entities.get(entity_name)

func add_projectile(projectile: Projectile) -> void:
	my_main.projectiles_spawner.spawn(ObjectHelpers.to_dict(projectile))

func add_decoration(sprite: Sprite2D) -> void:
	var decorations = get_tree().root.get_node("MyMain/Terrain/Decorations")
	decorations.add_child(sprite, true)

func spawn_moomoo() -> void:
	moomoo = my_main.moomoo_spawner.spawn({})
	add_entity(moomoo)
	print("Moomoo spawned: ", moomoo)

func spawn_player(spawn_data: Dictionary) -> void:
	var new_player = my_main.player_spawner.spawn(spawn_data)
	add_entity(new_player)
	print("Added player: " + new_player.name, " id: " + str(new_player.id))
	print("Total players: " + str(players_node.get_child_count()))

func spawn_enemy(enemy: Enemy) -> void:
	var new_enemy = my_main.enemies_spawner.spawn(ObjectHelpers.to_dict(enemy))
	add_entity(new_enemy)

# region 	SETTERs
func set_my_player(player: Player) -> void:
	MY_PLAYER = player
	my_main.gui_scene.init_scene(player)
# endregion SETTERs


# region 	GETTERs
func get_gui_scene() -> Node: return my_main.gui_scene
# endregion GETTERs
