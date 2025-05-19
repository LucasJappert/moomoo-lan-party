extends Node

var enemies_node: Node2D
var entities: Dictionary[String, Entity] = {}
var players_node: Node2D
var projectiles_node: Node2D
var moomoo_node
var moomoo: Moomoo

func _ready():
	pass

func add_enemy(enemy: Enemy) -> void:
	enemies_node.add_child(enemy, true)
	add_entity(enemy)

func add_entity(entity: Entity) -> void:
	entities[entity.name] = entity

func remove_entity(entity: Entity) -> void:
	var current_cell = AStarGridManager.world_to_cell(entity.global_position)
	AStarGridManager.set_cell_blocked(current_cell, false)
	entities.erase(entity.name)
	entity.queue_free()

func get_players() -> Array[Entity]:
	return entities.values().filter(func(e): return e is Player)

func get_enemies() -> Array[Entity]:
	return entities.values().filter(func(e): return e is Enemy)

func add_projectile(projectile: Projectile) -> void:
	projectiles_node.add_child(projectile, true)
