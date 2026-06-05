class_name MultiplayerInit
extends Node

func _ready():
	if OS.has_feature("web"):
		return
	var args := Array(OS.get_cmdline_args())
	if args.has("--server"):
		_start_server()

func _start_server() -> void:
	var port := _parse_port_arg()
	if port < 0:
		port = NetConfig.PORT
	var ws := WebSocketMultiplayerPeer.new()
	ws.create_server(port, "0.0.0.0")
	multiplayer.multiplayer_peer = ws
	print("Server started on 0.0.0.0:%d" % port)
	_load_game.call_deferred()

func _parse_port_arg() -> int:
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--port="):
			return int(arg.substr(7).strip_edges())
	return -1

func connect_to_server(ip: String, port: int, protocol: String = "wss") -> void:
	_load_game()
	await get_tree().process_frame

	var ws := WebSocketMultiplayerPeer.new()
	ws.create_client("%s://%s:%d" % [protocol, ip, port])
	multiplayer.multiplayer_peer = ws
	multiplayer.connected_to_server.connect(_on_connected, CONNECT_ONE_SHOT)
	print("Client connecting to %s://%s:%d" % [protocol, ip, port])

func _load_game() -> void:
	var scene := load("res://global/game.tscn")
	get_tree().root.add_child(scene.instantiate())

func _on_connected() -> void:
	LocalBus.connected.emit()
