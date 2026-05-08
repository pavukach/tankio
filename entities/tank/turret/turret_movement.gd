class_name TurretMovement
extends Node2D

@export var profile: TurretMovementProfile
@export var input: InputReader
var _angular_velocity := 0.0

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority() or not is_instance_valid(input):
		return

	var to_mouse := (input.mouse - global_position).normalized()
	var target_angle := to_mouse.angle() + PI / 2
	var angle_diff := wrapf(target_angle - global_rotation, -PI, PI)
	var desired_input := int(signf(angle_diff))

	var accel := MovementHelper.get_accel(
		desired_input,
		_angular_velocity,
		profile.acceleration,
		profile.friction,
		func (f): return _rotation_clamp(f, angle_diff),
	)
	
	_angular_velocity += accel
	rotation += _angular_velocity * delta
	rotation = clampf(rotation, -profile.max_angle_left, profile.max_angle_right)

func _rotation_clamp(v, diff: float):
	if abs(diff) < 0.01:
		return 0.0
	v = clampf(v, -profile.speed, profile.speed)
	return v
