class_name ProjectileProfile
extends Resource

@export var speed: float = 500.0
@export var damage: float = 10.0
@export var lifetime: float = 5.0

func to_dict() -> Dictionary:
	return {
		"speed": speed,
		"damage": damage,
		"lifetime": lifetime
	}

static func from_dict(data: Dictionary) -> ProjectileProfile:
	var profile = ProjectileProfile.new()
	if data.has("speed"): profile.speed = data["speed"]
	if data.has("damage"): profile.damage = data["damage"]
	if data.has("lifetime"): profile.lifetime = data["lifetime"]
	return profile
