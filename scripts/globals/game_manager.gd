extends Node

var enemies_node: Node2D
var enemies: Dictionary[int, Enemy] = {}
var players_node: Node2D
var players: Dictionary[int, Player] = {}
var projectiles_node: Node2D
var moomoo_node
var moomoo: Moomoo

func _ready():
	pass

func add_enemy(enemy: Enemy) -> void:
	enemies_node.add_child(enemy)
	enemies[enemy.id] = enemy

func add_projectile(projectile: Projectile) -> void:
	projectiles_node.add_child(projectile, true)

func get_entities() -> Array[Entity]:
	return cast_array_to_entity(get_players()) + cast_array_to_entity(get_enemies())

func get_enemies() -> Array[Enemy]:
	return enemies.values()

func get_players() -> Array[Player]:
	return players.values()

func cast_array_to_entity(arr: Array) -> Array[Entity]:
	var result: Array[Entity] = []
	for i in arr:
		result.append(i as Entity)
	return result