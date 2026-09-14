class_name NetObject
extends Node2D

var network_id: int
var network_methods: Array[NetFunc] = []


func register_method(callable: Callable, arg_types: Array[ByteData.Type], reliable: bool) -> int:
	var index := network_methods.size()
	network_methods.append(NetFunc.new(callable, arg_types, reliable))
	return index


func register_replication_method(
	callable: Callable,
	arg_types: Array[ByteData.Type],
	reliable: bool,
) -> int:
	var index := network_methods.size()
	network_methods.append(NetFunc.new(callable, arg_types, reliable, true))
	return index


func invoke_replication_method(
	method: NetFunc,
	args: Array,
	tick: int,
) -> void:
	if NetManager.network.is_server():
		method.invoke(args)
		return
	if NetManager.timeline.playhead() >= tick:
		method.invoke(args)
		return
	ReplicationTickWaiter.new(tick, func(): method.invoke(args))


func run_at_replication_tick(tick: int, action: Callable) -> void:
	if NetManager.network.is_server() or NetManager.timeline.playhead() >= tick:
		action.call()
		return
	ReplicationTickWaiter.new(tick, action)


func destroy() -> void:
	queue_free()
