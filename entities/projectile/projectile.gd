class_name Projectile
extends Area2D

const RAY_MULTIPLIER := 10.0

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
	var hit_pos := global_position

	var physics_body := body as PhysicsBody2D
	if physics_body:
		var shape_owner := physics_body.shape_find_owner(body_shape_index)
		if shape_owner != -1:
			var shape_node := physics_body.shape_owner_get_owner(shape_owner)
			if shape_node.has_method("apply_damage") and "thickness" in shape_node:
				var plate := shape_node as CollisionShape2D
				var bullet_dir := _velocity.normalized()
				var impact_normal := _get_impact_normal()
				var current_pen := profile.get_penetration(_lifetime_timer)
				var effective: float = plate.thickness
				var angle_deg := 0.0
				effective = profile.get_effective_armor(plate.thickness, impact_normal, bullet_dir)
				angle_deg = rad_to_deg(acos(clamp(-bullet_dir.dot(impact_normal), 0.0, 1.0)))
				var penetrated := current_pen > effective
				if penetrated:
					plate.apply_damage(profile.damage)
				_despawning = true
				rpc("hit_effect", hit_pos, penetrated)
				rpc("despawn")
				return

	var penetrated := false
	if _has_health(body):
		penetrated = true
		_hit_body(body)

	_despawning = true
	rpc("hit_effect", hit_pos, penetrated)
	rpc("despawn")


func _get_impact_normal() -> Vector2:
	var from := _previous_position
	var to := from + (global_position - from) * RAY_MULTIPLIER
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	return result.normal if result else Vector2.ZERO


func _has_health(body: Node2D) -> bool:
	if body.has_method("take_damage"):
		return true
	for child in body.get_children():
		if child.has_method("take_damage"):
			return true
	var parent := body.get_parent()
	if parent and parent.has_method("take_damage"):
		return true
	return false


func _hit_body(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(profile.damage)
		return

	for child in body.get_children():
		if child.has_method("take_damage"):
			child.take_damage(profile.damage)
			return

	var parent := body.get_parent()
	if parent:
		for child in parent.get_children():
			if child.has_method("take_damage"):
				child.take_damage(profile.damage)
				return


@rpc("authority", "call_remote", "reliable")
func hit_effect(pos: Vector2, penetrated_hit: bool):
	var effect := preload("res://entities/projectile/hit_effect.tscn").instantiate()
	effect.position = pos
	effect.penetrated = penetrated_hit
	ProjectileManager.instance.add_child(effect)


@rpc("authority", "call_local", "reliable")
func despawn():
	_despawning = true
	call_deferred("queue_free")
