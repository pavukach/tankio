class_name NetworkObject
extends Node2D

var network_id: int
var network_type: int
var owner_id: int

var network_methods: Array[NetFunc]
var network_vars: Array[NetVar]
var network_initial_vars: Array[NetVar]
var network_reliable_vars: Array[NetSyncVar]
var network_reliable_var_indices: Array[int]

signal created
signal destroyed


func _init() -> void:
	network_methods = [
		NetFunc.new(_on_create, [], true),
		NetFunc.new(_update_unreliable, [], false),
	]


func _ready() -> void:
	created.connect(NetInterest.on_entity_created.bind(self))
	destroyed.connect(NetInterest.on_entity_destroyed.bind(self))
	destroyed.connect(func(): if Network.is_server(): Network.release_entity(network_id))
	created.emit()


func _physics_process(_delta: float) -> void:
	if not Network.is_server() or not network_vars:
		return
	NetInterest.send(network_id, 1, network_vars.map(func(v): return v.get_value()))


func _on_create(...args: Array) -> void:
	for i in range(network_initial_vars.size()):
		network_initial_vars[i].set_value(args[i])


func register_initial_var(variable: NetSyncVar) -> void:
	network_initial_vars.append(variable)
	network_methods[0].get_args().append(variable.get_type())


func register_reliable_var(variable: NetSyncVar) -> void:
	var index := network_methods.size()

	network_methods.append(NetFunc.new(variable.set_value, [variable.get_type()], true))
	network_reliable_vars.append(variable)
	network_reliable_var_indices.append(index)
	if not Network.is_server():
		return
	variable.changed.connect(func(): NetInterest.send(network_id, index, [variable.get_value()]))


func register_var(variable: NetVar) -> void:
	network_vars.append(variable)
	network_methods[1].get_args().append(variable.get_type())


func register_method(callable: Callable, arg_types: Array[ByteData.Type], reliable: bool) -> int:
	var index := network_methods.size()
	network_methods.append(NetFunc.new(callable, arg_types, reliable))
	return index


func update_initial(player_id: int) -> void:
	if network_initial_vars.is_empty():
		return
	var initial_values: Array = []
	for v in network_initial_vars:
		initial_values.append(v.get_value())
	Network.send(player_id, network_id, 0, initial_values)


func update_reliable(player_id: int) -> void:
	for i in range(network_reliable_vars.size()):
		if network_reliable_vars[i].is_initial():
			continue
		Network.send(player_id, network_id, network_reliable_var_indices[i], [network_reliable_vars[i].get_value()])


func destroy() -> void:
	destroyed.emit()
	queue_free()


func _update_unreliable(...args: Array) -> void:
	for i in range(network_vars.size()):
		network_vars[i].set_value(args[i])
