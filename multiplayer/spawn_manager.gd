class_name SpawnManager
extends Node

var _entities: Dictionary[int, Node] = {}
var _data_to_send: Dictionary[int, PackedByteArray] = {}
var _entities_per_player: Dictionary[int, Dictionary] = {}

@export
var spawn_scenes: Array[PackedScene] = []

func order_spawn(type: int) -> void:
	var entity := spawn_scenes[type].instantiate()
	_entities[entity.get_instance_id()] = entity

func order_despawn(id: int) -> void:
	_entities.erase(id)
	for player_id in _entities_per_player:
		if id not in _entities_per_player[player_id]:
			continue
		_entities_per_player[player_id].erase(id)
		rpc_id(player_id, "despawn", id)

func order_update(id: int, data: PackedByteArray) -> void:
	_data_to_send[id] = data

func _physics_process(_delta: float) -> void:
	for player_id in _entities_per_player:
		var writer := ByteWriter.new()
		for id in _data_to_send[player_id]:
			if id not in _entities_per_player[player_id]:
				continue

			writer.append_int(id, 4)
			writer.append(_data_to_send[id])
		rpc_id(player_id, "update", writer.get_data())
	

@rpc("authority", "call_remote", "unreliable")
func update(player_data: PackedByteArray):
	var reader := ByteReader.new(player_data)
	while reader.has_data():
		var id := reader.get_int(4)
		if id not in _entities:
			continue

		var entity = _entities[id]
		entity.parse_sync_data(reader)

@rpc()
func spawn(id: int, type: int):
	var entity = spawn_scenes[type].instantiate()
	_entities[id] = entity

@rpc()
func despawn(id: int):
	if id not in _entities:
		return

	_entities[id].queue_free()
	_entities.erase(id)
