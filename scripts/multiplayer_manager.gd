# singleton autoload MultiplayerManager

extends Node

const SERVER_PORT = 8080
# const SERVER_IP = "192.168.0.3"
const SERVER_IP = "127.0.0.1"
const HOSTED_GAME = true

func become_host():
	var server = ENetMultiplayerPeer.new()
	server.create_server(SERVER_PORT, 2)
	print("Server running on port: " + str(SERVER_PORT))
	multiplayer.multiplayer_peer = server

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	Main.MY_PLAYER_ID = multiplayer.get_unique_id()
	_add_player_to_game(multiplayer.get_unique_id())

func become_client():
	var client = ENetMultiplayerPeer.new()
	client.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client
	Main.MY_PLAYER_ID = multiplayer.get_unique_id()

func _on_peer_connected(id):
	print("peer_connected: " + str(id))
	_add_player_to_game(id)

func _on_peer_disconnected(id):
	print("peer_disconnected: " + str(id))
	_remove_player_from_game(id)

func _add_player_to_game(id):
	var spawn_data = {
		"player_id": id
	}
	var main = get_tree().get_root().get_node("Main")
	var new_player = main.player_spawner.spawn(spawn_data)
	GameManager.add_entity(new_player)
	print("Added player: " + new_player.name)
	print("Total players: " + str(GameManager.players_node.get_child_count()))

func _remove_player_from_game(id):
	var player = GameManager.players_node.get_node(str(id))
	if player == null:
		return

	print("Removed player: " + player.name)
	GameManager.remove_entity(player)
