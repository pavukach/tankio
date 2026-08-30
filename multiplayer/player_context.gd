class_name PlayerContext
extends NetNode

const METHOD_INPUT := 2
const METHOD_SPAWN_REQUEST := 3
const METHOD_SPAWNED := 4
const METHOD_DIED := 5

var player_id: int
var player_name: String

var _input_reader: InputReader
var _bus: NetworkBus


func _ready() -> void:
	network_id = NetManager.network.CONTEXT_BASE + player_id
	NetManager.network.add_entity(network_id, self)
	super._ready()

	_bus = NetworkBus.new()
	add_child(_bus)

	if NetManager.network.is_server():
		_input_reader = InputReader.new()
		_input_reader.receiver = true
		add_child(_input_reader)
		_bus.spawn_requested.connect(_on_bus_spawn_requested)

	_register_methods()


func _register_methods() -> void:
	network_methods.append(NetFunc.new(
		_receive_input,
		[ByteData.Type.INT, ByteData.Type.INT, ByteData.Type.FLOAT, ByteData.Type.FLOAT, ByteData.Type.BYTE, ByteData.Type.BYTE],
		false,
	))
	network_methods.append(NetFunc.new(_request_spawn, [ByteData.Type.UINT], true))
	network_methods.append(NetFunc.new(_on_tank_spawned, [ByteData.Type.STRING], true))
	network_methods.append(NetFunc.new(_on_tank_died, [], true))


func attach_tank(tank: Tank) -> void:
	if _input_reader == null:
		return
	tank.attach_input(_input_reader)


func notify_spawned(tank_path: NodePath) -> void:
	_bus.send_spawned(tank_path)


func notify_died() -> void:
	_bus.send_died()


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


func _request_spawn(tank_entry_index: int) -> void:
	if NetManager.network.is_server():
		_bus.emit_spawn_requested(tank_entry_index)


func _on_tank_spawned(tank_path: String) -> void:
	if not NetManager.network.is_server():
		_bus.emit_tank_spawned(NodePath(tank_path))


func _on_tank_died() -> void:
	if not NetManager.network.is_server():
		_bus.emit_tank_died()


func _on_bus_spawn_requested(_peer_id: int, tank_entry_index: int) -> void:
	TankSpawner._on_spawn_requested(player_id, tank_entry_index)
