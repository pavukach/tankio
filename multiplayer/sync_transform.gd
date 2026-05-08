class_name SyncTransform
extends Node2D

@onready var body := get_parent()
var target_pos  := Vector2.ZERO
var target_rot := 0.0

var prev_pos  := Vector2.ZERO
var prev_rot := 0.0

var _since_update := 0.0

func _ready():
	target_pos = body.position
	prev_pos = body.position
	target_rot = body.rotation
	prev_rot = body.rotation
	
	if not is_multiplayer_authority():
		if body is RigidBody2D:
			body.freeze = true
			body.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

func _physics_process(_delta):
	if not is_multiplayer_authority():
		return
	rpc("sync_transform", body.position, body.rotation)

func _process(_delta):
	if is_multiplayer_authority():
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
