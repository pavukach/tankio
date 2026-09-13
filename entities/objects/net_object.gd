class_name NetObject
extends Node2D

## Base of everything the network can address. Shared state is an id and the
## methods others may call on it; NetNode adds replicated variables on top,
## NetHost adds nothing but the right to claim its own id.

var network_id: int
var network_methods: Array[NetFunc] = []


func register_method(callable: Callable, arg_types: Array[ByteData.Type], reliable: bool) -> int:
	var index := network_methods.size()
	network_methods.append(NetFunc.new(callable, arg_types, reliable))
	return index


func destroy() -> void:
	queue_free()