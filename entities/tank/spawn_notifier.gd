class_name SpawnNotifier
extends Node

func _ready() -> void:
	if Network.is_server():
		return
	var tank := owner as Tank
	if tank == null:
		return
	if tank.get_player_id() != Network.local_id():
		return
	LocalBus.local_player_spawned.emit(tank)
