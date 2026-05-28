class_name PositionTracker
extends Node2D

@export var body: Node2D
@export var max_history: int = 60

var _history: Array[Dictionary] = []

func _ready():
	if not body:
		body = get_parent()

func _physics_process(_delta):
	if not body or not is_instance_valid(body):
		return
	var now := Time.get_ticks_msec()
	var pos := body.global_position

	if not multiplayer.is_server():
		var sync := _find_sync_transform()
		if sync and sync.since_update < 0.05:
			pos = sync.target_pos

	_history.append({time = now, pos = pos})
	if _history.size() > max_history:
		_history.pop_front()

func _find_sync_transform() -> SyncTransform:
	var p := get_parent()
	if not p:
		return null
	for child in p.get_children():
		if child is SyncTransform:
			return child
	return null

func get_position_at(time_msec: int) -> Vector2:
	if _history.is_empty():
		return Vector2.ZERO
	for i in range(_history.size() - 1, -1, -1):
		if _history[i].time <= time_msec:
			return _history[i].pos
	return _history[0].pos
