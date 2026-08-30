extends Node

var _contexts: Dictionary[int, PlayerContext] = {}

func _ready() -> void:
	Network.peer_connected.connect(_on_peer_connected)
	Network.peer_disconnected.connect(_on_peer_disconnected)
	Network.connected_to_server.connect(_connect_local)


func _on_peer_connected(id: int) -> void:
	if Network.is_server():
		_connect_player(id)


func _connect_local() -> void:
	_connect_player(Network.local_id())


func _connect_player(player_id: int) -> void:
	var player_context: PlayerContext = PlayerContext.new()
	player_context.player_id = player_id
	player_context.player_name = str(player_id)
	add_child(player_context)
	_contexts[player_id] = player_context


func _on_peer_disconnected(player_id: int) -> void:
	var player_context: PlayerContext = _contexts.get(player_id)
	if player_context == null:
		return
	remove_child(player_context)
	player_context.queue_free()
	_contexts.erase(player_id)
