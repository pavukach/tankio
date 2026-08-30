class_name SyncPosition
extends Node2D

var _pos_x: NetSyncVar
var _pos_y: NetSyncVar
var _net: NetworkObject
var _parent: Node2D

var _seeded := false

var target_pos: Vector2:
	get:
		return Vector2(_pos_x.get_value(), _pos_y.get_value())


func _ready() -> void:
	process_physics_priority = -64

	_net = owner as NetworkObject
	_parent = get_parent() as Node2D

	_pos_x = NetSyncVar.new(0.0, ByteData.Type.FLOAT)
	_pos_y = NetSyncVar.new(0.0, ByteData.Type.FLOAT)

	_net.register_var(_pos_x)
	_net.register_var(_pos_y)
	_net.register_initial_var(_pos_x)
	_net.register_initial_var(_pos_y)

	if Network.is_server():
		_pos_x.set_value(_parent.global_position.x)
		_pos_y.set_value(_parent.global_position.y)
	else:
		_pos_x.changed.connect(_on_changed)
		_pos_y.changed.connect(_on_changed)


func _on_changed() -> void:
	if _seeded:
		return
	_seeded = true
	_seed.call_deferred()
	_pos_x.changed.disconnect(_on_changed)
	_pos_y.changed.disconnect(_on_changed)


func _seed() -> void:
	_parent.global_position = target_pos


func _physics_process(delta: float) -> void:
	if Network.is_server():
		_pos_x.set_value(_parent.global_position.x)
		_pos_y.set_value(_parent.global_position.y)
		return

	var weight := 1.0 - exp(
		-delta / NetConfig.INTERP_DELAY
	)

	_parent.global_position = _parent.global_position.lerp(
		target_pos,
		weight
	)
