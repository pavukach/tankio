class_name Shooter
extends Node2D

@export var input: InputReader
@export var profile: ShooterProfile
@export var muzzle: Marker2D

var _net: NetNode
var _reload_var: NetSyncVar
var _proj_index: int

var _is_reloading := false
var _reload_timer := 0.0


func _ready() -> void:
	_net = owner as NetNode
	_reload_var = NetSyncVar.new(0.0, ByteData.Type.FLOAT)
	_net.register_reliable_var(_reload_var)
	_reload_var.changed.connect(_on_reload_var_changed)
	_proj_index = NetManager.spawner.index_of_scene(profile.projectile_scene)
	if not NetManager.network.is_server():
		process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(_delta: float) -> void:
	if not NetManager.network.is_server() or not input:
		return

	if _is_reloading:
		_reload_timer -= _delta
		if _reload_timer <= 0.0:
			_is_reloading = false
		return

	if input.shooting:
		_fire()


func _fire() -> void:
	var spawn_pos := muzzle.global_position
	var angle := global_rotation
	var owner_id := _net.owner_id
	var entity := NetManager.spawner.spawn(_proj_index)
	var projectile := entity.find_child("Projectile", true, false) as Projectile
	projectile.setup(spawn_pos, angle, owner_id)
	reload()


func reload() -> void:
	if _is_reloading:
		return
	_reload_var.set_value(profile.reload_time)


func _on_reload_var_changed() -> void:
	var reload_time := _reload_var.get_value() as float
	if reload_time <= 0.0:
		return
	apply_reload(reload_time)
	LocalBus.reload_started.emit(_net.owner_id, reload_time)


func apply_reload(reload_time: float) -> void:
	_is_reloading = true
	_reload_timer = reload_time
