class_name PlayerSpawner
extends MultiplayerSpawner

@export var player: PackedScene

func _ready():
	spawn_function = _spawn_player

	if multiplayer.is_server():
		return
	rpc_id(1, "request_spawn", multiplayer.get_unique_id())

func _spawn_player(id):
	var p = player.instantiate()
	p.name = str(id)
	p.get_node("InputReader").set_multiplayer_authority(id)
	return p

@rpc("any_peer", "call_local")
func request_spawn(id: int):
	if not multiplayer.is_server():
		return
	spawn(id)

