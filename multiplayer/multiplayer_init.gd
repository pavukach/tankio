class_name MultiplayerInit
extends Node

func _ready():
	if OS.has_feature("web"):
		return
	var args := Array(OS.get_cmdline_args())
	if args.has("--server"):
		_start_server()

func _start_server() -> void:
	var ws := WebSocketMultiplayerPeer.new()
	ws.create_server(NetConfig.PORT, NetConfig.IP_ADDRESS)
	multiplayer.multiplayer_peer = ws
	print("Server started")
	_load_game.call_deferred()

func connect_to_server(ip: String, port: int) -> void:
	_load_game()
	await get_tree().process_frame

	var ws := WebSocketMultiplayerPeer.new()
	ws.create_client("ws://%s:%d" % [ip, port])
	multiplayer.multiplayer_peer = ws
	multiplayer.connected_to_server.connect(_on_connected, CONNECT_ONE_SHOT)
	print("Client connecting to %s:%d" % [ip, port])

func _load_game() -> void:
	var scene := load("res://global/game.tscn")
	get_tree().root.add_child(scene.instantiate())

func _on_connected() -> void:
	LocalBus.connected.emit()
