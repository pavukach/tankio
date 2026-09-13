class_name NetNode
extends NetObject

## Reserved method slots. Every entity replicates its initial state through
## one and its per-tick snapshot through the other, so registered methods and
## reliable variables are numbered from here on.
const METHOD_CREATE := 0
const METHOD_SNAPSHOT := 1

var network_type: int
var owner_id: int

var network_vars: Array[NetVar]
var network_initial_vars: Array[NetVar]
var network_reliable_vars: Array[NetVar]
var network_reliable_var_indices: Array[int]

signal created
signal destroyed


func _init() -> void:
	network_methods = [
		NetFunc.new(_on_create, [], true),
		NetFunc.new(_update_unreliable, [], false),
	]


func _ready() -> void:
	created.connect(NetManager.interest.on_entity_created.bind(self))
	destroyed.connect(NetManager.interest.on_entity_destroyed.bind(self))
	destroyed.connect(func(): if NetManager.network.is_server(): NetManager.network.release_entity(network_id))
	created.emit()


func _on_create(...args: Array) -> void:
	var tick := NetManager.network.packet_tick
	for i in range(network_initial_vars.size()):
		network_initial_vars[i].receive(args[i], tick)


func register_initial_var(variable: NetVar) -> void:
	network_initial_vars.append(variable)
	network_methods[METHOD_CREATE].get_args().append(variable.get_type())


func register_reliable_var(variable: NetVar) -> void:
	var index := network_methods.size()

	network_methods.append(NetFunc.new(variable.set_value, [variable.get_type()], true))
	network_reliable_vars.append(variable)
	network_reliable_var_indices.append(index)
	if not NetManager.network.is_server():
		return
	variable.changed.connect(func(): NetManager.interest.send(network_id, index, [variable.get_value()]))


func register_var(variable: NetVar) -> void:
	network_vars.append(variable)
	network_methods[METHOD_SNAPSHOT].get_args().append(variable.get_type())


func update_initial(player_id: int) -> void:
	if network_initial_vars.is_empty():
		return
	var initial_values: Array = []
	for v in network_initial_vars:
		initial_values.append(v.get_value())
	NetManager.network.send(player_id, network_id, METHOD_CREATE, initial_values)


func update_reliable(player_id: int) -> void:
	for i in range(network_reliable_vars.size()):
		if network_reliable_vars[i].is_initial():
			continue
		NetManager.network.send(player_id, network_id, network_reliable_var_indices[i], [network_reliable_vars[i].get_value()])


## Keeps a newly replicated entity out of sight until the playhead reaches the
## tick it was spawned on. The node itself has to exist right away so that the
## snapshots addressed to it can be buffered, but showing it immediately would
## put it on screen ahead of the state around it.
func hide_until_tick(tick: int) -> void:
	visible = false
	NetManager.timeline.at_tick(tick, func(): visible = true)


func destroy() -> void:
	destroyed.emit()
	queue_free()


func _update_unreliable(...args: Array) -> void:
	var tick := NetManager.network.packet_tick
	for i in range(network_vars.size()):
		network_vars[i].receive(args[i], tick)