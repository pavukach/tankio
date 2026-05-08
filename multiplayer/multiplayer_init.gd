class_name MultiplayerInit
extends Node

func _ready():
	var args := Array(OS.get_cmdline_args())
	var peer := ENetMultiplayerPeer.new()

	if args.has("--server"):
		peer.create_server(NetConfig.PORT, NetConfig.MAX_CLIENTS)
		multiplayer.multiplayer_peer = peer
		_load_game()
		print("Server started")
		return

	peer.create_client(NetConfig.IP_ADDRESS, NetConfig.PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_load_game)
	print("Client started")

func _load_game():
	get_tree().call_deferred("change_scene_to_file", "res://global/game.tscn")
