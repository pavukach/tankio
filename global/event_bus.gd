extends Node

signal spawn_requested(peer_id: int, tank_entry_index: int)
signal tank_spawned(tank_path: NodePath)
signal tank_died()
signal health_updated(tank_id: int, current_health: float, max_health: float)
signal reload_started(tank_id: int, reload_time: float)

func request_spawn(tank_entry_index: int):
	rpc_id(1, "_on_request_spawn", tank_entry_index)

func send_spawned(peer_id: int, tank_path: NodePath):
	rpc_id(peer_id, "_on_tank_spawned", tank_path)

func send_died(peer_id: int):
	rpc_id(peer_id, "_on_tank_died")

@rpc("any_peer", "call_remote", "reliable")
func _on_request_spawn(tank_entry_index: int):
	spawn_requested.emit(multiplayer.get_remote_sender_id(), tank_entry_index)

@rpc("authority", "call_remote", "reliable")
func _on_tank_spawned(tank_path: NodePath):
	tank_spawned.emit(tank_path)

@rpc("authority", "call_remote", "reliable")
func _on_tank_died():
	tank_died.emit()


