class_name InputReader
extends Node

var move := Vector2i.ZERO
var mouse := Vector2.ZERO
var shooting := false
var ability := false

var camera: Camera2D

var receiver := false

var _active := false


func _ready() -> void:
	if receiver:
		return
	if NetManager.network.is_server():
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	LocalBus.local_player_spawned.connect(_on_local_player_spawned)


func _on_local_player_spawned(_tank: Tank) -> void:
	_active = true


func apply_remote(
	move_x: int,
	move_y: int,
	peer_mouse: Vector2,
	peer_shoot: bool,
	peer_ability: bool,
) -> void:
	move = Vector2i(move_x, move_y)
	mouse = peer_mouse
	shooting = peer_shoot
	ability = peer_ability


func _process(_delta: float) -> void:
	if receiver or NetManager.network.is_server() or not _active:
		return
	if NetManager.network.peer == null or NetManager.network.peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return

	move.x = int(Input.is_action_pressed("player_right")) - int(Input.is_action_pressed("player_left"))
	move.y = int(Input.is_action_pressed("player_backward")) - int(Input.is_action_pressed("player_forward"))
	shooting = Input.is_action_pressed("player_shoot")
	ability = Input.is_action_pressed("player_ability")

	if camera == null:
		camera = get_viewport().get_camera_2d()
	mouse = camera.get_global_mouse_position()

	if not NetManager.network.is_server():
		NetManager.network.send(
			1,
			NetworkCore.CONTEXT_ENTITY,
			PlayerContext.METHOD_INPUT,
			[move.x, move.y, mouse.x, mouse.y, 1 if shooting else 0, 1 if ability else 0],
		)