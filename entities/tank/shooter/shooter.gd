class_name Shooter
extends Node2D

@export var input: InputReader
@export var profile: ShooterProfile
@export var muzzle: Marker2D

var _is_reloading := false
var _reload_timer := 0.0
var _projectile_manager: ProjectileManager

func _ready():
	if not is_multiplayer_authority():
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	_projectile_manager = ProjectileManager.instance

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority() or not input:
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
	var proj_profile := ProjectileProfile.new()
	var tank := Tank.find_in(self)
	var owner_id := tank.get_player_id() if tank else 0
	var proj_data := ProjectileSpawnData.new(spawn_pos, angle, owner_id, proj_profile)
	_projectile_manager.spawn(proj_data.to_dict())
	reload()


func reload() -> void:
	if _is_reloading:
		return
	_is_reloading = true
	_reload_timer = profile.reload_time
