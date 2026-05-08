class_name TurretMovementProfile
extends Resource

@export_range(0, 180, 1, "radians_as_degrees") var speed: float
@export_range(0, 180, 1, "radians_as_degrees") var acceleration: float
@export_range(0, 1800, 1, "radians_as_degrees") var friction: float

@export var use_angles: bool
@export_range(0, 180, 1, "radians_as_degrees") var max_angle_left: float
@export_range(0, 180, 1, "radians_as_degrees") var max_angle_right: float
