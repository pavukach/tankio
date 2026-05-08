class_name ProjectileManager
extends MultiplayerSpawner

@export var projectile_scene: PackedScene

static var instance: ProjectileManager

func _ready():
	spawn_function = _spawn_projectile
	instance = self


func _spawn_projectile(data: Variant) -> Node:
	if not data is Dictionary:
		print("Error: Received invalid spawn data for projectile (expected Dictionary)")
		return null
	
	var p_data := ProjectileSpawnData.from_dict(data)
	
	if projectile_scene == null:
		print("Error: projectile_scene is null in ProjectileManager")
		return null
		
	var scene: Projectile = projectile_scene.instantiate()
	if scene == null:
		print("Error: Failed to instantiate projectile scene")
		return null
		
	scene.setup(p_data.from_pos, p_data.angle, p_data.shooter, p_data.profile)
	return scene
