class_name ProjectileSpawnData
extends Resource

@export var from_pos: Vector2
@export var angle: float
@export var shooter: int
@export var profile: ProjectileProfile

func _init(p_from_pos: Vector2 = Vector2.ZERO, p_angle: float = 0.0, p_shooter: int = 0, p_profile: ProjectileProfile = null) -> void:
	from_pos = p_from_pos
	angle = p_angle
	shooter = p_shooter
	profile = p_profile

func to_dict() -> Dictionary:
	return {
		"from_pos": from_pos,
		"angle": angle,
		"shooter": shooter,
		"profile": profile.to_dict() if profile else {}
	}

static func from_dict(data: Dictionary) -> ProjectileSpawnData:
	var res = ProjectileSpawnData.new()
	if data.has("from_pos"): res.from_pos = data["from_pos"]
	if data.has("angle"): res.angle = data["angle"]
	if data.has("shooter"): res.shooter = data["shooter"]
	if data.has("profile"):
		res.profile = ProjectileProfile.from_dict(data["profile"])
	return res
