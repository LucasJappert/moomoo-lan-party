extends Node

var enemies_node: Node2D
var entities: Dictionary[String, Entity] = {}
var players_node: Node2D
var projectiles_node: Node2D
var moomoo_node
var moomoo: Moomoo
var my_trees_node
var terrain

func _ready():
	enemies_node = get_tree().root.get_node("Main/Enemies")
	players_node = get_tree().root.get_node("Main/Players")
	moomoo_node = get_tree().root.get_node("Main/Moomoo")
	projectiles_node = get_tree().root.get_node("Main/Projectiles")
	my_trees_node = get_tree().root.get_node("Main/MyTrees")
	terrain = get_tree().root.get_node("Main/Terrain")
	pass

func add_enemy(enemy: Enemy) -> void:
	enemies_node.add_child(enemy, true)
	add_entity(enemy)

func add_my_tree(my_tree: MyTree) -> void:
	my_trees_node.add_child(my_tree)
	MapManager.set_cell_blocked(MapManager.world_to_cell(my_tree.global_position), true)

func add_entity(entity: Entity) -> void:
	var safe_cell = MapManager.get_safe_cell(MapManager.world_to_cell(entity.global_position))
	if safe_cell == null:
		print("⚠️ No safe cell found for entity: " + entity.name)
		return

	entity.global_position = MapManager.cell_to_world(safe_cell)
	entities[entity.name] = entity
	MapManager.set_cell_blocked(safe_cell, true)

func remove_entity(entity: Entity) -> void:
	var current_cell = MapManager.world_to_cell(entity.global_position)
	MapManager.set_cell_blocked(current_cell, false)
	entities.erase(entity.name)
	entity.queue_free()

func get_players() -> Array[Entity]:
	return entities.values().filter(func(e): return e is Player)

func get_enemies() -> Array[Entity]:
	return entities.values().filter(func(e): return e is Enemy)

func add_projectile(projectile: Projectile) -> void:
	projectiles_node.add_child(projectile, true)

func add_decoration(sprite: Sprite2D) -> void:
	var decorations = get_tree().root.get_node("Main/Terrain/Decorations")
	decorations.add_child(sprite, true)
