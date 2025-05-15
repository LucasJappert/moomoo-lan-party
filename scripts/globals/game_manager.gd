extends Node

var enemies_nodes: Node2D
var enemies: Dictionary[int, Enemy] = {}
var players_node: Node2D
var players: Dictionary[int, Player] = {}
var moomoo_node
var moomoo: Moomoo

func _ready():
	print("GameManager globals ready")

func add_enemy(enemy: Enemy) -> void:
	enemies_nodes.add_child(enemy)
	enemies[enemy.id] = enemy

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