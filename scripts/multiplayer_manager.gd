extends Node

const SERVER_PORT = 8080
# const SERVER_IP = "192.168.0.3"
const SERVER_IP = "127.0.0.1"

const player_scene = preload("res://scenes/entity/player_scene.tscn")
var players_node # Just for the server

func become_host():
	print("become_host")
	players_node = get_tree().get_root().get_node("Game/Players")
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
	var player = player_scene.instantiate()
	player.set_player_id(id)
	player.global_position = Vector2(4 * 64 + 16, 4 * 64 + 16)
	players_node.add_child(player, true)

	if multiplayer.is_server():
		player.get_node("InputSynchronizer").set_multiplayer_authority(id) # 👈 Esto es clave

	GameManager.players[id] = player
	AStarGridManager.set_cell_blocked_from_world(player.global_position, true)
	print("Added player: " + player.name)
	print("Total players: " + str(players_node.get_child_count()))

func _remove_player_from_game(id):
	GameManager.players.erase(id)
	var player = players_node.get_node(str(id))
	if player == null:
		return

	player.queue_free()
