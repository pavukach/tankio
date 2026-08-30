class_name SyncRotation
extends Node2D

@export var use_local_rotation := false

var _rot: NetSyncVar
var _net: NetworkObject
var _parent: Node2D

var _seeded := false

var target_rot: float:
	get:
		return _rot.get_value()


func _ready() -> void:
	process_physics_priority = -64

	_net = owner as NetworkObject
	_parent = get_parent() as Node2D

	_rot = NetSyncVar.new(0.0, ByteData.Type.FLOAT)

	_net.register_var(_rot)
	_net.register_initial_var(_rot)

	if Network.is_server():
		_rot.set_value(_parent.rotation if use_local_rotation else _parent.global_rotation)
	else:
		_rot.changed.connect(_on_changed)


func _on_changed() -> void:
	if _seeded:
		return
	_seeded = true
	_apply_parent(target_rot)
	_rot.changed.disconnect(_on_changed)


func _physics_process(delta: float) -> void:
	if Network.is_server():
		_rot.set_value(_parent.rotation if use_local_rotation else _parent.global_rotation)
		return

	var weight := 1.0 - exp(
		-delta / NetConfig.INTERP_DELAY
	)

	var current := parent_rotation()
	_apply_parent(lerp_angle(current, target_rot, weight))


func parent_rotation() -> float:
	return _parent.rotation if use_local_rotation else _parent.global_rotation


func _apply_parent(rot: float) -> void:
	if use_local_rotation:
		_parent.rotation = rot
	else:
		_parent.global_rotation = rot
