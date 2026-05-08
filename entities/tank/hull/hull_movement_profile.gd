class_name HullMovementProfile
extends Resource

@export var speed: float
@export var reverse_speed: float
@export var acceleration: float
@export var friction: float

@export_range(0, 180, 1, "radians_as_degrees") var turn_speed: float
@export_range(0, 180, 1, "radians_as_degrees") var turn_acceleration: float
@export_range(0, 1800, 1, "radians_as_degrees") var turn_friction: float
