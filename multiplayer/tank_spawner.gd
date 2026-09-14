extends Node

@export var tank_entries: Array[TankEntry] = []
@export var spawn_points_root: NodePath

var _spawn_points: Array[Node2D] = []
var _player_tanks: Dictionary[int, Node2D] = {}

const PROJECTILE_SCENES := [
	preload("res://entities/projectile/projectiles/valentine_projectile.tscn"),
	preload("res://entities/projectile/projectiles/pz_iii_projectile.tscn"),
]


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

	var scenes: Array[PackedScene] = []
	for entry in tank_entries:
		scenes.append(entry.tank_scene)
	for proj in PROJECTILE_SCENES:
		scenes.append(proj)
	NetManager.spawner.entities = scenes
	NetManager.spawner.rebuild_index()

	NetManager.network.peer_disconnected.connect(_on_peer_disconnected)


func setup():
	spawn_points_root = NodePath("/root/Game/World/SpawnPoints")
	_collect_spawn_points()


func _collect_spawn_points():
	var node := get_node(spawn_points_root)
	for child in node.get_children():
		_spawn_points.append(child)


func _configure_tank(t: Tank, id: int) -> void:
	t.set_meta("peer_id", id)
	t.owner_id = id
	t.add_to_group(str(id))
	for child in t.find_children("*", "", true, false):
		child.add_to_group(str(id))

	t.get_node("Health").died.connect(_on_tank_died.bind(t))


func _on_spawn_requested(peer_id: int, tank_entry_index: int) -> void:
	var spawn_position: Vector2
	var spawn_rotation: float
	var old_tank := _player_tanks.get(peer_id) as Tank

	if old_tank:
		spawn_position = old_tank.hull.global_position
		spawn_rotation = old_tank.hull.global_rotation
		old_tank.destroy()
	else:
		var spawn_point = _spawn_points[randi() % _spawn_points.size()]
		spawn_position = spawn_point.position
		spawn_rotation = spawn_point.rotation

	var tank := NetManager.spawner.spawn(
		tank_entry_index,
		Transform2D(spawn_rotation, spawn_position),
	) as Tank
	_configure_tank(tank, peer_id)
	NetManager.interest.start_tracking(tank.network_id, peer_id)
	_player_tanks[peer_id] = tank

	var ctx := NetManager.network.get_context(peer_id) as PlayerContext
	ctx.attach_tank(tank)
	ctx.bus.send_spawned(tank.get_path())

	var spawn_zone := InterestZone.new(peer_id, InterestZone.SPAWN_RADIUS, InterestZone.Type.SPAWN)
	var despawn_zone := InterestZone.new(peer_id, InterestZone.DESPAWN_RADIUS, InterestZone.Type.DESPAWN)
	tank.hull.add_child(spawn_zone)
	tank.hull.add_child(despawn_zone)


func _on_peer_disconnected(peer_id: int) -> void:
	var tank := _player_tanks.get(peer_id) as Tank
	if not tank:
		return
	_player_tanks.erase(peer_id)
	tank.destroy()


func _on_tank_died(tank: Tank) -> void:
	var peer_id := tank.get_meta("peer_id") as int
	_player_tanks.erase(peer_id)
	var ctx := NetManager.network.get_context(peer_id) as PlayerContext
	ctx.bus.send_died()
	tank.destroy()