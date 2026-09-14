class_name PlayerContext
extends NetHost

const METHOD_INPUT := 0
const METHOD_SPAWN_REQUEST := 1
const METHOD_SPAWNED := 2
const METHOD_DIED := 3

var player_id: int
var player_name: String

var _input_reader: InputReader
var bus: NetworkBus


func _ready() -> void:
	if NetManager.network.is_server():
		NetManager.network.register_context(player_id, self)
	else:
		claim_id(NetworkCore.CONTEXT_ENTITY)

	bus = NetworkBus.new()
	add_child(bus)

	if NetManager.network.is_server():
		_input_reader = InputReader.new()
		_input_reader.receiver = true
		add_child(_input_reader)
		bus.spawn_requested.connect(_on_bus_spawn_requested)

	_register_methods()


func _exit_tree() -> void:
	if NetManager.network.is_server():
		NetManager.network.unregister_context(player_id)


func _register_methods() -> void:
	network_methods.append(NetFunc.new(
		_receive_input,
		[
			ByteData.Type.INT,
			ByteData.Type.INT,
			ByteData.Type.FLOAT,
			ByteData.Type.FLOAT,
			ByteData.Type.BYTE,
			ByteData.Type.BYTE,
		],
		false,
	))
	network_methods.append(NetFunc.new(
		_request_spawn,
		[ByteData.Type.PEER, ByteData.Type.UINT],
		true,
	))
	network_methods.append(NetFunc.new(_on_tank_spawned, [ByteData.Type.STRING], true))
	network_methods.append(NetFunc.new(_on_tank_died, [], true))


func attach_tank(tank: Tank) -> void:
	if _input_reader == null:
		return
	tank.attach_input(_input_reader)


func _receive_input(
	move_x: int,
	move_y: int,
	mouse_x: float,
	mouse_y: float,
	shooting: int,
	ability: int,
) -> void:
	if _input_reader:
		_input_reader.apply_remote(move_x, move_y, Vector2(mouse_x, mouse_y), shooting != 0, ability != 0)


func _request_spawn(sender_peer: int, tank_entry_index: int) -> void:
	if NetManager.network.is_server():
		bus.spawn_requested.emit(sender_peer, tank_entry_index)


func _on_tank_spawned(tank_path: String) -> void:
	if not NetManager.network.is_server():
		bus.tank_spawned.emit(NodePath(tank_path))


func _on_tank_died() -> void:
	if not NetManager.network.is_server():
		bus.tank_died.emit()


func _on_bus_spawn_requested(peer_id: int, tank_entry_index: int) -> void:
	TankSpawner._on_spawn_requested(peer_id, tank_entry_index)