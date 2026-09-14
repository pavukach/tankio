class_name FollowPlayer
extends Camera2D

var _parent: Node2D

func _ready():
	var tank := owner as Tank
	var player_id := tank.owner_id
	if NetManager.network.local_id() != player_id:
		enabled = false
		return
	
	enabled = true
	make_current()
	print("follow player")
	top_level = true
	_parent = get_parent() as Node2D

func _process(_delta):
	if not enabled:
		return
	global_position = _parent.global_position
	global_rotation = 0