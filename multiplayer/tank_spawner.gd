class_name TankSpawner
extends MultiplayerSpawner

@export var tank_entries: Array[TankEntry] = []
@export var spawn_points_root: NodePath

var _spawn_points: Array[Node2D] = []
var _player_tanks: Dictionary[int, Node2D] = {}

func _ready():
	if tank_entries.is_empty():
		var default_entry := TankEntry.new()
		default_entry.display_name = "Default"
		default_entry.tank_scene = load("res://entities/tank/tank.tscn")
		tank_entries.append(default_entry)

		var fast_entry := TankEntry.new()
		fast_entry.display_name = "Fast"
		fast_entry.tank_scene = load("res://entities/tank/tank_fast.tscn")
		tank_entries.append(fast_entry)

	if multiplayer.is_server():
		EventBus.spawn_requested.connect(_on_spawn_requested)

	spawn_function = _spawn_tank
	_collect_spawn_points()

func _collect_spawn_points():
	var node := get_node_or_null(spawn_points_root)
	if not node:
		return

	for child in node.get_children():
		_spawn_points.append(child)

func _spawn_tank(data: Dictionary):
	var entry: TankEntry = tank_entries[data.tank_entry_index]
	var id: int = data.id
	var t: Node2D = entry.tank_scene.instantiate()
	t.name = str(id)
	t.position = data.position
	t.rotation = data.rotation

	var tank_input := t.get_node_or_null("InputReader")
	if tank_input:
		tank_input.set_multiplayer_authority(id)

	var tank_health := t.get_node_or_null("Health") as Health
	if tank_health:
		tank_health.died.connect(_on_tank_died.bind(t))

	return t

func _on_spawn_requested(peer_id: int, tank_entry_index: int) -> void:
	var spawn_position: Vector2
	var spawn_rotation: float
	var old_tank := _player_tanks.get(peer_id) as Node2D

	if old_tank and is_instance_valid(old_tank):
		var hull := old_tank.get_node_or_null("Hull") as Node2D
		if hull:
			spawn_position = hull.global_position
			spawn_rotation = hull.global_rotation
		else:
			spawn_position = old_tank.position
			spawn_rotation = old_tank.rotation
		old_tank.rpc("despawn")
	else:
		var spawn_point = _spawn_points[peer_id % _spawn_points.size()]
		spawn_position = spawn_point.position
		spawn_rotation = spawn_point.rotation

	var data := {id = peer_id, position = spawn_position, rotation = spawn_rotation, tank_entry_index = tank_entry_index}
	var tank := spawn(data) as Node2D
	if not tank:
		return
	_player_tanks[peer_id] = tank
	EventBus.send_spawned(peer_id, tank.get_path())

func _on_tank_died(tank: Node2D) -> void:
	var peer_id := int(tank.name)
	_player_tanks.erase(peer_id)
	EventBus.send_died(peer_id)
	tank.rpc("despawn")
