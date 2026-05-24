class_name FollowPlayer
extends Camera2D

func _ready():
	var tank := Tank.find_in(self)
	var player_id := tank.get_player_id() if tank else 0
	if multiplayer.get_unique_id() != player_id:
		enabled = false
		return
	
	enabled = true
	make_current()
	print("follow player")
	top_level = true

func _process(_delta):
	if not enabled:
		return
		
	if not is_instance_valid(get_parent()):
		queue_free()
		return
	
	global_position = get_parent().global_position
	global_rotation = 0
