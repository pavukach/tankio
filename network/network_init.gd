class_name NetworkInit
extends Node

func _ready():
	if OS.has_feature("web"):
		return
	if OS.get_environment("TANKIO_SERVER") == "1":
		_start_server()

func _start_server() -> void:
	var port := _parse_port()
	if port < 0:
		port = NetConfig.PORT
	var ws := WebSocketMultiplayerPeer.new()
	ws.create_server(port, NetConfig.BIND_ADDRESS)
	NetManager.network.set_peer(ws, true)
	print("Server started on %s:%d" % [NetConfig.BIND_ADDRESS, port])
	_load_game.call_deferred()

func _parse_port() -> int:
	var p := OS.get_environment("TANKIO_PORT")
	if p.is_empty():
		return -1
	return int(p.strip_edges())

func connect_to_server(ip: String, port: int, protocol: String = "wss") -> void:
	_load_game()
	await get_tree().process_frame

	var ws := WebSocketMultiplayerPeer.new()
	ws.create_client("%s://%s:%d" % [protocol, ip, port])
	NetManager.network.set_peer(ws, false)
	NetManager.network.connected_to_server.connect(_on_connected, CONNECT_ONE_SHOT)
	print("Client connecting to %s://%s:%d" % [protocol, ip, port])

func _load_game() -> void:
	var scene := load("res://global/game.tscn")
	get_tree().root.add_child(scene.instantiate())

func _on_connected() -> void:
	LocalBus.connected.emit()
