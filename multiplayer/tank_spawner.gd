extends MultiplayerSpawner

@export var tank_entries: Array[TankEntry] = []
@export var spawn_points_root: NodePath

var _spawn_points: Array[Node2D] = []
var _player_tanks: Dictionary[int, Node2D] = {}
var _spawn_data: Dictionary[int, Dictionary] = {}

func _ready():
	if tank_entries.is_empty():
		var valentine_entry := TankEntry.new()
		valentine_entry.display_name = "Valentine"
		valentine_entry.tank_scene = load("res://entities/tank/valentine/valentine.tscn")
		tank_entries.append(valentine_entry)

		var pziii_entry := TankEntry.new()
		pziii_entry.display_name = "Pz III"
		pziii_entry.tank_scene = load("res://entities/tank/pz_iii/pz_iii.tscn")
		tank_entries.append(pziii_entry)

	if multiplayer.is_server():
		NetworkBus.spawn_requested.connect(_on_spawn_requested)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	spawn_function = _spawn_tank


func setup():
	spawn_path = NodePath("/root/Game/World")
	spawn_points_root = NodePath("/root/Game/World/SpawnPoints")
	_collect_spawn_points()


func _collect_spawn_points():
	var node := get_node_or_null(spawn_points_root)
	if not node:
		return

	for child in node.get_children():
		_spawn_points.append(child)

func _spawn_tank(data: Dictionary) -> Node2D:
	print("Spawning tank, id: %d" % data.id)
	var entry: TankEntry = tank_entries[data.tank_entry_index]
	var id: int = data.id
	var t: Node2D = entry.tank_scene.instantiate()
	t.set_meta("peer_id", id)
	t.add_to_group(str(id))
	for child in t.find_children("*", "", true, false):
		child.add_to_group(str(id))
	t.position = data.position
	t.rotation = data.rotation

	var tank_input := t.get_node_or_null("InputReader")
	if tank_input:
		tank_input.set_multiplayer_authority(id)

	var tank_health := t.get_node_or_null("Health") as Health
	if tank_health:
		tank_health.died.connect(_on_tank_died.bind(t))

	print("Spawned tank")
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
		var spawn_point = _spawn_points[randi() % _spawn_points.size()]
		spawn_position = spawn_point.position
		spawn_rotation = spawn_point.rotation

	var data := {id = peer_id, position = spawn_position, rotation = spawn_rotation, tank_entry_index = tank_entry_index}
	var tank := spawn(data) as Node2D
	if not tank:
		return
	_player_tanks[peer_id] = tank
	_spawn_data[peer_id] = data
	NetworkBus.send_spawned(peer_id, tank.get_path())

func _on_peer_disconnected(peer_id: int) -> void:
	var tank := _player_tanks.get(peer_id) as Node2D
	if tank and is_instance_valid(tank):
		_on_tank_died(tank)

func _on_tank_died(tank: Node2D) -> void:
	var peer_id := tank.get_meta("peer_id") as int
	_player_tanks.erase(peer_id)
	_spawn_data.erase(peer_id)
	NetworkBus.send_died(peer_id)
	tank.rpc("despawn")
