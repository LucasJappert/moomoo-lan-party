extends Node

const SERVER_PORT = 8080
# const SERVER_IP = "192.168.0.3"
const SERVER_IP = "127.0.0.1"

# const player_scene = preload("res://scenes/entity/player_scene.tscn")

func become_host():
	print("become_host")
	var server = ENetMultiplayerPeer.new()
	server.create_server(SERVER_PORT, 2)
	print("Server running on port: " + str(SERVER_PORT))
	multiplayer.multiplayer_peer = server

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	_add_player_to_game(multiplayer.get_unique_id())

func become_client():
	print("become_client")
	var client = ENetMultiplayerPeer.new()
	client.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client

func _on_peer_connected(id):
	print("peer_connected: " + str(id))
	_add_player_to_game(id)

func _on_peer_disconnected(id):
	print("peer_disconnected: " + str(id))
	_remove_player_from_game(id)

func _add_player_to_game(id):
	var spawn_data = {
		"player_id": id,
	}
	var main = get_tree().get_root().get_node("Main")
	var new_player = main.player_spawner.spawn(spawn_data)
	GameManager.players[id] = new_player
	AStarGridManager.set_cell_blocked_from_world(new_player.global_position, true)
	print("Added player: " + new_player.name)
	print("Total players: " + str(GameManager.players_node.get_child_count()))

func _remove_player_from_game(id):
	GameManager.players.erase(id)
	var player = GameManager.players_node.get_node(str(id))
	if player == null:
		return

	player.queue_free()
