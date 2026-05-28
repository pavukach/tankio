class_name InputReader
extends Node

var move := Vector2i.ZERO
var mouse := Vector2.ZERO
var shooting := false
var ability := false

var camera: Camera2D

func _ready():
	if not multiplayer.is_server() and not is_multiplayer_authority():
		queue_free()
		return
	camera = get_viewport().get_camera_2d()


func _process(_delta):
	var mp := multiplayer.multiplayer_peer
	if mp == null or mp.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	if not is_multiplayer_authority():
		return

	move.x = int(Input.is_action_pressed("player_right")) - int(Input.is_action_pressed("player_left"))
	move.y = int(Input.is_action_pressed("player_backward")) - int(Input.is_action_pressed("player_forward"))
	shooting = Input.is_action_pressed("player_shoot")
	ability = Input.is_action_pressed("player_ability")

	if camera:
		mouse = camera.get_global_mouse_position()

	if not multiplayer.is_server():
		rpc_id(1, "send_input", move, mouse, shooting, ability)

@rpc("any_peer", "call_remote", "unreliable")
func send_input(peer_move: Vector2, peer_mouse: Vector2, peer_shoot: bool, peer_ability: bool):
	move = Vector2i(peer_move)
	mouse = peer_mouse
	shooting = peer_shoot
	ability = peer_ability
