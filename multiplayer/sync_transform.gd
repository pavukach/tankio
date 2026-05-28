class_name SyncTransform
extends Node2D

@export var body: Node2D

func _ready():
	if not body:
		body = get_parent()
	target_pos = body.position
	target_rot = body.rotation
	if not is_multiplayer_authority():
		if body is RigidBody2D:
			body.freeze = true
			body.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

var target_pos := Vector2.ZERO
var target_rot := 0.0
var _velocity := Vector2.ZERO
var _angular_velocity := 0.0
var _since_update := 0.0

var since_update: float:
	get:
		return _since_update

func _physics_process(_delta):
	if not is_multiplayer_authority() or not body or not is_inside_tree():
		return
	rpc("sync_transform", body.position, body.rotation)


func _process(_delta):
	if is_multiplayer_authority() or not body:
		return

	_since_update += _delta
	body.position = target_pos + _velocity * _since_update
	body.rotation = target_rot + _angular_velocity * _since_update


@rpc("authority", "call_remote", "unreliable")
func sync_transform(peer_position: Vector2, peer_rotation: float):
	if _since_update > 0:
		_velocity = (peer_position - target_pos) / _since_update
		_angular_velocity = wrapf(peer_rotation - target_rot, -PI, PI) / _since_update
	target_pos = peer_position
	target_rot = peer_rotation
	_since_update = 0
