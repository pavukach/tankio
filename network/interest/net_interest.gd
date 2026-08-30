extends Node

const INTEREST_LAYER := 2

var entity_per_player: Dictionary[int, Array] = {}

func on_entity_created(entity: NetworkObject) -> void:
	entity_per_player[entity.network_id] = []


func on_entity_destroyed(entity: NetworkObject) -> void:
	var players: Array = entity_per_player.get(entity.network_id, [])
	for player_id in players:
		Network.send(player_id, NetworkSpawner.network_id, 1, [entity.network_id])
	entity_per_player.erase(entity.network_id)


func start_tracking(entity_id: int, player_id: int) -> void:
	if player_id in entity_per_player.get(entity_id, []):
		return
	entity_per_player[entity_id].append(player_id)
	var entity: NetworkObject = Network.get_entity(entity_id)
	Network.send(player_id, NetworkSpawner.network_id, 0, [entity_id, entity.network_type, entity.owner_id])
	entity.update_initial(player_id)
	entity.update_reliable(player_id)

func stop_tracking(entity_id: int, player_id: int) -> void:
	entity_per_player[entity_id].erase(player_id)
	Network.send(player_id, NetworkSpawner.network_id, 1, [entity_id])

func send(entity_id: int, method_id: int, payload: Array) -> void:
	for player in entity_per_player.get(entity_id, []):
		Network.send(player, entity_id, method_id, payload)