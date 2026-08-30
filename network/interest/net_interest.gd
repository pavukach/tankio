class_name NetInterest
extends RefCounted

const INTEREST_LAYER := 2

var _network: NetworkCore
var _spawner: NetSpawner

var entity_per_player: Dictionary[int, Array] = {}


func _init(p_network: NetworkCore, p_spawner: NetSpawner) -> void:
	_network = p_network
	_spawner = p_spawner


func on_entity_created(entity: NetNode) -> void:
	entity_per_player[entity.network_id] = []


func on_entity_destroyed(entity: NetNode) -> void:
	var players: Array = entity_per_player.get(entity.network_id, [])
	for player_id in players:
		_network.send(player_id, _spawner.network_id, 1, [entity.network_id])
	entity_per_player.erase(entity.network_id)


func start_tracking(entity_id: int, player_id: int) -> void:
	if player_id in entity_per_player.get(entity_id, []):
		return
	entity_per_player[entity_id].append(player_id)
	var entity: NetNode = _network.get_entity(entity_id)
	_network.send(player_id, _spawner.network_id, 0, [entity_id, entity.network_type, entity.owner_id])
	entity.update_initial(player_id)
	entity.update_reliable(player_id)

func stop_tracking(entity_id: int, player_id: int) -> void:
	entity_per_player[entity_id].erase(player_id)
	_network.send(player_id, _spawner.network_id, 1, [entity_id])

func send(entity_id: int, method_id: int, payload: Array) -> void:
	for player in entity_per_player.get(entity_id, []):
		_network.send(player, entity_id, method_id, payload)
