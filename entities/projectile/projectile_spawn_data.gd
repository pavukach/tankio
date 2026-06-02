class_name ProjectileSpawnData
extends Resource

@export var from_pos: Vector2
@export var angle: float
@export var shooter: int
@export var scene_path: String

func _init(p_from_pos: Vector2 = Vector2.ZERO, p_angle: float = 0.0, p_shooter: int = 0, p_scene_path: String = "") -> void:
	from_pos = p_from_pos
	angle = p_angle
	shooter = p_shooter
	scene_path = p_scene_path

func to_dict() -> Dictionary:
	return {
		"from_pos": from_pos,
		"angle": angle,
		"shooter": shooter,
		"scene_path": scene_path,
	}

static func from_dict(data: Dictionary) -> ProjectileSpawnData:
	var res = ProjectileSpawnData.new()
	if data.has("from_pos"): res.from_pos = data["from_pos"]
	if data.has("angle"): res.angle = data["angle"]
	if data.has("shooter"): res.shooter = data["shooter"]
	if data.has("scene_path"): res.scene_path = data["scene_path"]
	return res
