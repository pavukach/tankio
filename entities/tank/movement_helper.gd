class_name MovementHelper

static func get_accel(
	input_value: int,
	cur_speed: float,
	accel: float,
	friction: float,
	transform_fn: Callable,
) -> float:
	var speed_sign := signf(cur_speed)
	var speed_delta := 0.0

	var allowed_cur: float = transform_fn.call(cur_speed)
	var over_limit: bool = abs(cur_speed) > abs(allowed_cur)
	
	if speed_sign != input_value or over_limit:
		var friction_val := minf(abs(cur_speed), friction)
		speed_delta = -friction_val * speed_sign
	if input_value != 0:
		speed_delta += input_value * accel
	
	var target := cur_speed + speed_delta
	target = transform_fn.call(target)
	
	return target - cur_speed
