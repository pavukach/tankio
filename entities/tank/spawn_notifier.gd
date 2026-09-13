class_name SpawnNotifier
extends Node

func _ready() -> void:
	if NetManager.network.is_server():
		return
	var tank := owner as Tank
	if tank == null:
		return
	if tank.owner_id != NetManager.network.local_id():
		return
	LocalBus.local_player_spawned.emit(tank)