class_name SyncTransform
extends Node2D

@export var body: Node2D

func _ready():
	if not body:
		body = get_parent()
	target_pos = body.position
	prev_pos = body.position
	target_rot = body.rotation
	prev_rot = body.rotation
	_ready_body()

func _ready_body():
	if not is_multiplayer_authority():
		if body is RigidBody2D:
			body.freeze = true
			body.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

var target_pos := Vector2.ZERO
var target_rot := 0.0
var prev_pos := Vector2.ZERO
var prev_rot := 0.0
var _since_update := 0.0

func _physics_process(_delta):
	var mp := multiplayer.multiplayer_peer
	if mp == null or mp.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	if not is_multiplayer_authority() or not body or not is_inside_tree():
		return
	rpc("sync_transform", body.position, body.rotation)


func _process(_delta):
	var mp := multiplayer.multiplayer_peer
	if mp == null or mp.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	if is_multiplayer_authority() or not body:
		return

	_since_update += _delta
	var t := _since_update / NetConfig.UPDATE_INTERVAL
	t = clamp(t, 0.0, 1.0)
	body.position = prev_pos.lerp(target_pos, t)
	body.rotation = lerp_angle(prev_rot, target_rot, t)

@rpc("authority", "call_remote", "unreliable")
func sync_transform(peer_position: Vector2, peer_rotation: float):
	prev_pos = target_pos
	prev_rot = target_rot
	target_pos = peer_position
	target_rot = peer_rotation
	_since_update = 0
