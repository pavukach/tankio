class_name NetworkBus
extends Node

signal spawn_requested(peer_id: int, tank_entry_index: int)
signal tank_spawned(tank_path: NodePath)
signal tank_died()


func request_spawn(tank_entry_index: int) -> void:
	var ctx := get_parent() as PlayerContext
	NetManager.network.send(1, ctx.network_id, PlayerContext.METHOD_SPAWN_REQUEST, [tank_entry_index])


func send_spawned(tank_path: NodePath) -> void:
	var ctx := get_parent() as PlayerContext
	NetManager.network.send(ctx.player_id, ctx.network_id, PlayerContext.METHOD_SPAWNED, [str(tank_path)])


func send_died() -> void:
	var ctx := get_parent() as PlayerContext
	NetManager.network.send(ctx.player_id, ctx.network_id, PlayerContext.METHOD_DIED, [])