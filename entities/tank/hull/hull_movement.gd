class_name HullMovement extends RigidBody2D

@export var profile: HullMovementProfile
@export var input: InputReader
var rotation_speed: float

func _ready():
	angular_damp = 0
	linear_damp = 0

func _process(_delta):
	pass

func _integrate_forces(state):
	if not is_multiplayer_authority():
		return
	
	_move(state)
	_apply_side_friction(state)
	_rotate(state)

func _move(state: PhysicsDirectBodyState2D):
	var local_v := state.transform.basis_xform_inv(state.linear_velocity)
	
	var accel := MovementHelper.get_accel(
		input.move.y, 
		local_v.y,   
		profile.acceleration,
		profile.friction,
		func (f: float): return clampf(f, -profile.speed, profile.reverse_speed),
	)
	var new_local := local_v
	new_local.y += accel
	state.linear_velocity = state.transform.basis_xform(new_local)

func _apply_side_friction(state: PhysicsDirectBodyState2D):
	var v := state.linear_velocity
	var local_v := state.transform.basis_xform_inv(v)
	var side_speed := local_v.x
	
	if side_speed != 0:
		var friction_val := minf(abs(side_speed), profile.friction)
		var friction_delta := -signf(side_speed) * friction_val
		local_v.x += friction_delta
		
		var new_velocity = state.transform.basis_xform(local_v)
		state.linear_velocity = new_velocity



func _rotate(state: PhysicsDirectBodyState2D):
	var local_v := state.transform.basis_xform_inv(state.linear_velocity)
	var desired = input.move.x * (-1 if local_v.y > 0 else 1)
	var accel := MovementHelper.get_accel(
		desired,
		state.angular_velocity,
		profile.turn_acceleration,
		profile.turn_friction,
		func (f: float): return clampf(f, -profile.turn_speed, profile.turn_speed),
	)
	state.angular_velocity += accel
