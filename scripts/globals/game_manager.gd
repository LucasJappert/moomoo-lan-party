extends Node

var my_main: Node2D
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

func _ready():
	my_main = get_tree().root.get_node("MyMain")
	enemies_node = get_tree().root.get_node("MyMain/Enemies")
	players_node = get_tree().root.get_node("MyMain/Players")
	moomoo_node = get_tree().root.get_node("MyMain/Moomoo")
	projectiles_node = get_tree().root.get_node("MyMain/Projectiles")
	my_trees_node = get_tree().root.get_node("MyMain/MyTrees")
	terrain = get_tree().root.get_node("MyMain/Terrain")
	audio_node = get_tree().root.get_node("MyMain/Audio")

	enemies_node.connect("child_entered_tree", func(p_enemy: Enemy): add_entity(p_enemy))
	enemies_node.connect("child_exiting_tree", func(p_enemy: Enemy): remove_entity(p_enemy))
	players_node.connect("child_entered_tree", func(p_player: Player): add_entity(p_player))
	players_node.connect("child_exiting_tree", func(p_player: Player): remove_entity(p_player))
	moomoo_node.connect("child_entered_tree", func(p_moomoo: Moomoo): add_entity(p_moomoo))
	moomoo_node.connect("child_exiting_tree", func(p_moomoo: Moomoo): remove_entity(p_moomoo))

	call_deferred("_init_projectiles_spawner")
	call_deferred("_init_enemies_spawner")
	call_deferred("_init_moomoo_spawner")
	

func _init_projectiles_spawner() -> void:
	my_main.projectiles_spawner.spawn_function = func(data: Dictionary) -> Node:
		return Projectile.get_instance_from_dict(data)

func _init_enemies_spawner() -> void:
	my_main.enemies_spawner.spawn_function = func(data: Dictionary) -> Node:
		return Enemy.get_instance_from_dict(data)

func _init_moomoo_spawner() -> void:
	my_main.moomoo_spawner.spawn_function = func(data: Dictionary) -> Node:
		return Moomoo.get_instance_from_dict(data)

func _process(delta: float) -> void:
	CursorManager._static_process(delta)
	MyCamera.process(delta)


func add_enemy(enemy: Enemy) -> void:
	my_main.enemies_spawner.spawn(ObjectHelpers.to_dict(enemy))

func add_my_tree(my_tree: MyTree) -> void:
	my_trees_node.add_child(my_tree, true)
	MapManager.set_cell_blocked(MapManager.world_to_cell(my_tree.global_position), true)

func add_entity(entity: Entity) -> void:
	entities[entity.name] = entity

	if not AM_I_HOST: return

	var safe_cell = MapManager.get_safe_cell(MapManager.world_to_cell(entity.global_position))
	if safe_cell == null:
		return print("⚠️ No safe cell found for entity: " + entity.name)

	entity.global_position = MapManager.cell_to_world(safe_cell)
	MapManager.set_cell_blocked(safe_cell, true)

func remove_entity(entity: Entity) -> void:
	entities.erase(entity.name)

	if not AM_I_HOST: return
	var current_cell = MapManager.world_to_cell(entity.global_position)
	MapManager.set_cell_blocked(current_cell, false)
	entity.queue_free() # We shouldn't do this in the client side, server should do it and sync it

func get_players() -> Array[Entity]:
	return entities.values().filter(func(e): return e is Player)

func get_enemies() -> Array[Entity]:
	return entities.values().filter(func(e): return e is Enemy)

func get_entity(entity_name: String) -> Entity:
	return entities.get(entity_name)

func add_projectile(projectile: Projectile) -> void:
	my_main.projectiles_spawner.spawn(ObjectHelpers.to_dict(projectile))

func add_decoration(sprite: Sprite2D) -> void:
	var decorations = get_tree().root.get_node("MyMain/Terrain/Decorations")
	decorations.add_child(sprite, true)

func spawn_moomoo() -> void:
	moomoo = Moomoo.get_instance()
	my_main.moomoo_spawner.spawn(ObjectHelpers.to_dict(moomoo))
	MapManager.set_cell_blocked_from_world(GameManager.moomoo.global_position, true)

# region 	SETTERs
func set_my_player(player: Player) -> void:
	MY_PLAYER = player
	my_main.gui_scene.init_scene(player)
# endregion SETTERs


# region 	GETTERs
func show_tooltip(title: String, text: String, panel_width: int = 0) -> void:
	my_main.gui_scene.my_tooltip.show_me(title, text, panel_width)
func hide_tooltip() -> void:
	my_main.gui_scene.my_tooltip.hide_me()
# endregion GETTERs
