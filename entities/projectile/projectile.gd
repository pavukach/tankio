class_name Projectile
extends Area2D

var owner_id: int
var _velocity := Vector2.ZERO
var _lifetime := 5.0
var _lifetime_timer := 0.0

@export var profile: ProjectileProfile

func _ready():
	body_entered.connect(_handle_collision)
	if not is_multiplayer_authority():
		monitoring = false
		monitorable = false
	


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		_lifetime_timer += delta
		if _lifetime_timer >= _lifetime:
			$SyncTransform.rpc("despawn")
			return
		position += _velocity * delta


func setup(
	from_pos: Vector2,
	angle: float,
	p_owner_id: int,
	p_profile: ProjectileProfile,
) -> void:
	position = from_pos
	rotation = angle
	profile = p_profile
	_velocity = Vector2.from_angle(angle - PI / 2) * profile.speed
	owner_id = p_owner_id
	_lifetime = p_profile.lifetime


func _handle_collision(node: Node2D) -> void:
	if not is_instance_valid(node):
		return
	if node.name == str(owner_id):
		return
	if node.get_parent() and node.get_parent().name == str(owner_id):
		return

	apply_hit()
	$SyncTransform.rpc("despawn")


func apply_hit() -> void:
	pass
