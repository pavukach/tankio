class_name ProjectileManager
extends MultiplayerSpawner

func _ready():
	spawn_path = NodePath(".")
	spawn_function = _spawn_projectile


func _spawn_projectile(data: Variant) -> Node:
	if not data is Dictionary:
		print("Error: Received invalid spawn data for projectile (expected Dictionary)")
		return null
	
	var p_data := ProjectileSpawnData.from_dict(data)
	
	var projectile_scene := load(p_data.scene_path) as PackedScene
	
	var scene: Projectile = projectile_scene.instantiate()

	scene.setup(p_data.from_pos, p_data.angle, p_data.shooter)
	return scene
