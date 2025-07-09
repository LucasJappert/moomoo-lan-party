# singleton autoload MultiplayerManager

extends Node

const SERVER_PORT = 2222

func become_client():
	var client = ENetMultiplayerPeer.new()
	var ip: String = GameManager.get_gui_scene().text_ip.text
	client.create_client(ip, SERVER_PORT)
	multiplayer.multiplayer_peer = client
	# var enet_peer = client.get_peer(1)
	# enet_peer.set_timeout(0, 0, 30_000)
	GameManager.MY_PLAYER_ID = multiplayer.get_unique_id()

func _on_peer_connected(id):
	print("peer_connected: " + str(id))
	# _add_player_to_game(id)

func _on_peer_disconnected(id):
	print("peer_disconnected: " + str(id))
