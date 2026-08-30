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
	NetworkSpawner.entities = scenes
	NetworkSpawner.rebuild_index()

	if Network.is_server():
		Network.peer_disconnected.connect(_on_peer_disconnected)


func setup():
	spawn_points_root = NodePath("/root/Game/World/SpawnPoints")
	_collect_spawn_points()


func _collect_spawn_points():
	var node := get_node_or_null(spawn_points_root)
	if not node:
		return

	for child in node.get_children():
		_spawn_points.append(child)


func _configure_tank(t: Node2D, id: int) -> void:
	t.set_meta("peer_id", id)
	t.owner_id = id
	t.add_to_group(str(id))
	for child in t.find_children("*", "", true, false):
		child.add_to_group(str(id))

	var tank_health := t.get_node_or_null("Health") as Health
	if tank_health:
		tank_health.died.connect(_on_tank_died.bind(t))


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
		if old_tank is NetworkObject:
			old_tank.destroy()
		else:
			old_tank.queue_free()
	else:
		var spawn_point = _spawn_points[randi() % _spawn_points.size()]
		spawn_position = spawn_point.position
		spawn_rotation = spawn_point.rotation

	var tank := NetworkSpawner.spawn(tank_entry_index, Transform2D(spawn_rotation, spawn_position))
	if not tank:
		return
	_configure_tank(tank, peer_id)
	NetInterest.start_tracking(tank.network_id, peer_id)
	_player_tanks[peer_id] = tank

	var ctx := Network.get_entity(Network.CONTEXT_BASE + peer_id) as PlayerContext
	if ctx:
		ctx.attach_tank(tank)
		ctx.notify_spawned(tank.get_path())

	var spawn_zone := InterestZone.new(peer_id, 2000, InterestZone.Type.SPAWN)
	var despawn_zone := InterestZone.new(peer_id, 2500, InterestZone.Type.DESPAWN)
	tank.add_child(spawn_zone)
	tank.add_child(despawn_zone)


func _on_peer_disconnected(peer_id: int) -> void:
	var tank := _player_tanks.get(peer_id) as Node2D
	if tank and is_instance_valid(tank):
		_on_tank_died(tank)


func _on_tank_died(tank: Node2D) -> void:
	var peer_id := tank.get_meta("peer_id") as int
	_player_tanks.erase(peer_id)
	var ctx := Network.get_entity(Network.CONTEXT_BASE + peer_id) as PlayerContext
	if ctx:
		ctx.notify_died()
	if tank is NetworkObject:
		tank.destroy()
	else:
		tank.queue_free()
