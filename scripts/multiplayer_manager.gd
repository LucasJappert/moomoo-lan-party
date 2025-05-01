extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

const player_scene = preload("res://scenes/player.tscn")
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
	player.peer_id = id
	players_node.add_child(player)

func _remove_player_from_game(id):
	var player = players_node.get_node(str(id))
	if player == null:
		return

	player.queue_free()
