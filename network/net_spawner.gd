class_name NetSpawner
extends NetHost

const METHOD_SPAWN := 0
const METHOD_DESPAWN := 1

var world: Node
@export var entities: Array[PackedScene]

var scene_to_index: Dictionary = {}


func _ready() -> void:
	claim_id(NetManager.network.acquire_id())
	network_methods = [
		NetFunc.new(_spawn_remote, [ByteData.Type.UINT, ByteData.Type.UINT, ByteData.Type.UINT], true),
		NetFunc.new(_despawn_remote, [ByteData.Type.UINT], true),
	]


func _world() -> Node:
	if world == null or not is_instance_valid(world):
		world = get_node("/root/Game/World")
	return world


func index_of_scene(scene: PackedScene) -> int:
	return scene_to_index.get(scene.resource_path, -1)


func rebuild_index() -> void:
	scene_to_index.clear()
	for i in entities.size():
		scene_to_index[entities[i].resource_path] = i


func spawn(entity_index: int, initial_transform := Transform2D.IDENTITY) -> NetNode:
	if not NetManager.network.is_server():
		push_error("Can only spawn entities on the server")
		return null
	var entity = entities[entity_index].instantiate()

	if entity is not NetNode:
		push_error("Can only spawn NetworkObjects")
		return null
	var id := NetManager.network.acquire_id()
	NetManager.network.add_entity(id, entity)
	entity.network_id = id
	entity.network_type = entity_index
	entity.transform = initial_transform
	_world().add_child(entity)
	return entity


func replicate_spawn(player_id: int, entity: NetNode) -> void:
	NetManager.network.send(
		player_id,
		network_id,
		METHOD_SPAWN,
		[entity.network_id, entity.network_type, entity.owner_id],
	)
	entity.update_initial(player_id)
	entity.update_reliable(player_id)


func replicate_despawn(player_id: int, entity_id: int) -> void:
	NetManager.network.send(player_id, network_id, METHOD_DESPAWN, [entity_id])


func _spawn_remote(entity_id: int, index: int, owner_id: int) -> void:
	var entity = entities[index].instantiate()
	entity.network_id = entity_id
	entity.network_type = index
	entity.owner_id = owner_id
	NetManager.network.add_entity(entity_id, entity)
	entity.add_to_group(str(owner_id))
	entity.set_meta("peer_id", owner_id)
	_world().add_child(entity)
	entity.hide_until_tick(NetManager.network.packet_tick)


func _despawn_remote(entity_id: int) -> void:
	var entity = NetManager.network.get_entity(entity_id)
	if entity == null or entity.is_queued_for_deletion():
		return
	NetManager.network.remove_entity(entity_id)
	entity.queue_free()