class_name NetFunc
extends RefCounted

var _func: Callable
var _reliable: bool
var _args: Array[ByteData.Type]
var wait_for_packet_tick := false

func _init(
	p_func: Callable,
	args: Array[ByteData.Type],
	p_reliable: bool,
	p_wait_for_packet_tick: bool = false,
) -> void:
	_func = p_func
	_args = args
	_reliable = p_reliable
	wait_for_packet_tick = p_wait_for_packet_tick

func invoke(args: Array) -> void:
	_func.callv(args)

func get_args() -> Array[ByteData.Type]:
	return _args

func is_reliable() -> bool:
	return _reliable
