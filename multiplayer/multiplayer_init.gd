class_name MultiplayerInit
extends Node

func _ready():
	if OS.has_feature("web"):
		return
	var args := Array(OS.get_cmdline_args())
	if args.has("--server"):
		_start_server()
		queue_free()

func _start_server() -> void:
	var ws := WebSocketMultiplayerPeer.new()
	ws.create_server(NetConfig.PORT, NetConfig.IP_ADDRESS)
	multiplayer.multiplayer_peer = ws
	_load_game()
	print("Server started")

func connect_to_server(ip: String, port: int) -> void:
	var ws := WebSocketMultiplayerPeer.new()
	ws.create_client("ws://%s:%d" % [ip, port])

	multiplayer.multiplayer_peer = ws
	multiplayer.connected_to_server.connect(_on_connected, CONNECT_ONE_SHOT)

	print("Client connecting to %s:%d" % [ip, port])

func _on_connected() -> void:
	_load_game()

func _load_game() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://global/game.tscn")
