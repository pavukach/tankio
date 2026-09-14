class_name ReplicationTickWaiter
extends RefCounted

var _tick: int
var _action: Callable


func _init(tick: int, action: Callable) -> void:
	_tick = tick
	_action = action
	NetManager.timeline.tick_passed.connect(_on_tick_passed)


func _on_tick_passed(passed_tick: int) -> void:
	if passed_tick < _tick:
		return
	NetManager.timeline.tick_passed.disconnect(_on_tick_passed)
	if _action.is_valid():
		_action.call()
