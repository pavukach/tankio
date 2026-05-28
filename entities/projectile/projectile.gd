class_name Projectile
extends Area2D

var owner_id: int
var _velocity := Vector2.ZERO
var _lifetime := 5.0
var _lifetime_timer := 0.0
var _previous_position := Vector2.ZERO
var _despawning := false
var _hit_handled := false

@export var profile: ProjectileProfile

func _ready():
	body_shape_entered.connect(_handle_body_collision)
	if not is_multiplayer_authority():
		monitoring = false
		monitorable = false


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_previous_position = global_position
		_lifetime_timer += delta
		if _lifetime_timer >= _lifetime:
			rpc("despawn")
			return
		position += _velocity * delta


func setup(
	from_pos: Vector2,
	angle: float,
	p_owner_id: int,
) -> void:
	position = from_pos
	rotation = angle
	_velocity = Vector2.from_angle(angle - PI / 2) * profile.speed
	owner_id = p_owner_id
	_lifetime = profile.lifetime
	_previous_position = from_pos


func _handle_body_collision(_body_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	if _despawning or _hit_handled or not is_instance_valid(body):
		return
	if body.is_in_group(str(owner_id)):
		return

	_hit_handled = true

	var result: Dictionary = HitResolver.resolve(
		body, body_shape_index,
		get_world_2d(), _velocity, profile, _lifetime_timer,
		_previous_position, global_position,
	)
	if not result.handled:
		return

	_despawning = true
	rpc("hit_effect", result.hit_pos, result.penetrated)
	rpc("despawn")


@rpc("authority", "call_remote", "reliable")
func hit_effect(pos: Vector2, penetrated_hit: bool):
	var effect: Node2D = preload("res://entities/projectile/hit_effect.tscn").instantiate()
	effect.position = pos
	effect.penetrated = penetrated_hit
	ProjManager.add_child(effect)


@rpc("authority", "call_local", "reliable")
func despawn():
	_despawning = true
	call_deferred("queue_free")
