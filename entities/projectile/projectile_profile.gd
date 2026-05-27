class_name ProjectileProfile
extends Resource

@export var speed: float = 500.0
@export var damage: float = 10.0
@export var lifetime: float = 5.0
@export var penetration: float = 50.0
@export var decay_rate: float = 0.0
@export var normalization: float = 0.0

func get_penetration(time_elapsed: float) -> float:
	return max(0.0, penetration - decay_rate * time_elapsed)

func get_effective_armor(raw_thickness: float, impact_normal: Vector2, bullet_dir: Vector2) -> float:
	var incidence := acos(clamp(-bullet_dir.dot(impact_normal), 0.0, 1.0))
	var adjusted: float = max(0.0, incidence - deg_to_rad(normalization))
	return raw_thickness / max(cos(adjusted), 0.01)

func to_dict() -> Dictionary:
	return {
		"speed": speed,
		"damage": damage,
		"lifetime": lifetime,
		"penetration": penetration,
		"decay_rate": decay_rate,
		"normalization": normalization,
	}

static func from_dict(data: Dictionary) -> ProjectileProfile:
	var profile = ProjectileProfile.new()
	if data.has("speed"): profile.speed = data["speed"]
	if data.has("damage"): profile.damage = data["damage"]
	if data.has("lifetime"): profile.lifetime = data["lifetime"]
	if data.has("penetration"): profile.penetration = data["penetration"]
	if data.has("decay_rate"): profile.decay_rate = data["decay_rate"]
	if data.has("normalization"): profile.normalization = data["normalization"]
	return profile
