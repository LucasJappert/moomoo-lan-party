extends Node

var main_scene: MainScene
var game_world: GameWorld

var entities: Dictionary[String, Entity] = {}
var moomoo: Moomoo

var MY_PLAYER: Player
var MY_PLAYER_ID: int = -1
var AM_I_HOST = true

func _ready():
	# main_scene = get_tree().get_root().get_node("MainScene")
	pass

func _init_projectiles_spawner() -> void:
	game_world.projectiles_spawner.spawn_function = func(data: Dictionary) -> Node:
		return Projectile.get_instance_from_dict(data)

func _process(delta: float) -> void:
	CursorManager._static_process(delta)
	WindowFocusWatcher._process(delta)
	EnemiesWavesController._process(delta)

func add_my_tree(my_tree: MyTree) -> void:
	game_world.my_trees_node.add_child(my_tree, true)
	MapManager.set_cell_blocked(MapManager.world_to_cell(my_tree.global_position), true)

func add_entity(entity: Entity) -> void:
	if entity is Enemy:
		GameWorld.current_enemies_in_scene += 1
	entities[entity.name] = entity

	if not AM_I_HOST: return

	var safe_cell = MapManager.get_safe_cell(MapManager.world_to_cell(entity.global_position))
	if safe_cell == null:
		return print("⚠️ No safe cell found for entity: " + entity.name)
	
	if entity.movement_helper.current_cell != safe_cell:
		print("⚠️ safe_cell, entity.current_cell: " + str(safe_cell) + ", " + str(entity.movement_helper.current_cell))

	entity.global_position = MapManager.cell_to_world(safe_cell)
	MapManager.set_cell_blocked(safe_cell, true)

func remove_entity(entity_died: Entity, killed_by: Entity) -> void:
	entities.erase(entity_died.name)
	_actions_for_server_side_after_entity_removed(entity_died, killed_by)

func _actions_for_server_side_after_entity_removed(entity_died: Entity, killed_by: Entity) -> void:
	if not AM_I_HOST: return
	
	if entity_died is Enemy:
		GameWorld.current_enemies_in_scene -= 1
		if GameWorld.current_enemies_in_scene == 0: EventBus.emit_wave_finilized()
	
	EventBus.emit_freed_entity(entity_died.name)
	EventBus.emit_entity_died(entity_died, killed_by)

	SkillBase.remove_effects_running_by_owner_name(entity_died.name)
	
	entity_died.queue_free() # We shouldn't do this in the client side, server should do it and sync it


func _on_enemy_exited_tree() -> void:
	GameWorld.current_enemies_in_scene -= 1

func get_players() -> Array[Entity]:
	# TODO: Improve with cache by frame
	return entities.values().filter(func(e): return e is Player)

func get_enemies() -> Array[Entity]:
	return entities.values().filter(func(e): return e is Enemy)

func get_moomoo() -> Entity: return moomoo

func get_entities() -> Array[Entity]: return entities.values()

func get_entity(entity_name: String) -> Entity:
	return entities.get(entity_name)

func add_projectile(projectile: Projectile) -> void:
	game_world.projectiles_spawner.spawn(ObjectHelpers.to_dict(projectile))

func add_decoration(sprite: Sprite2D) -> void:
	game_world.decorations_node.add_child(sprite, true)

func spawn_moomoo() -> void:
	moomoo = game_world.moomoo_spawner.spawn({})
	add_entity(moomoo)

func spawn_player(hero_type: String) -> void:
	GameManager.MY_PLAYER_ID = 1
	var spawn_data = {
		"player_id": 1,
		"key_type": hero_type
	}
	var new_player = game_world.player_spawner.spawn(spawn_data)
	add_entity(new_player)

func spawn_enemy(enemy: Enemy) -> void:
	var new_enemy = game_world.enemies_spawner.spawn(ObjectHelpers.to_dict(enemy))
	add_entity(new_enemy)

# region 	SETTERs
func set_my_player(player: Player) -> void:
	MY_PLAYER = player
	game_world.gui_scene.init_scene(player)
# endregion SETTERs


# region 	GETTERs
func get_gui_scene() -> Node: return game_world.gui_scene
# endregion GETTERs
