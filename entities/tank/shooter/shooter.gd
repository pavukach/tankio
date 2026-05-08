class_name Shooter
extends Node2D

@export var player: Node
@export var input: InputReader
@export var profile: ShooterProfile
@export var projectile_manager: ProjectileManager

var _is_reloading := false
var _reload_timer := 0.0
var _muzzle: Node2D

func _ready():
	if not is_multiplayer_authority():
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	_muzzle = $Muzzle
	projectile_manager = ProjectileManager.instance

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

		
	if _is_reloading:
		_reload_timer -= _delta
		if _reload_timer <= 0.0:
			_is_reloading = false
		return	

	if input.shooting:
		_fire()


func _fire() -> void:
	var spawn_pos := _muzzle.global_position
	var angle := global_rotation
	var proj_profile := ProjectileProfile.new()
	var proj_data := ProjectileSpawnData.new(spawn_pos, angle, int(player.name), proj_profile)
	projectile_manager.spawn(proj_data.to_dict())
	reload()


func reload() -> void:
	if _is_reloading:
		return
	_is_reloading = true
	_reload_timer = profile.reload_time
