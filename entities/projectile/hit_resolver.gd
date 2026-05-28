class_name HitResolver
extends RefCounted

const RAY_MULTIPLIER := 10.0

static func resolve(
	body: Node2D,
	body_shape_index: int,
	projectile_world: World2D,
	velocity: Vector2,
	profile: ProjectileProfile,
	lifetime_timer: float,
	previous_position: Vector2,
	current_position: Vector2,
) -> Dictionary:
	var hit_pos := current_position

	var physics_body := body as PhysicsBody2D
	if physics_body:
		var shape_owner := physics_body.shape_find_owner(body_shape_index)
		if shape_owner != -1:
			var shape_node := physics_body.shape_owner_get_owner(shape_owner)
			if shape_node.has_method("apply_damage") and "thickness" in shape_node:
				var plate := shape_node as CollisionShape2D
				var bullet_dir := velocity.normalized()
				var impact_normal := _get_impact_normal(previous_position, current_position, projectile_world)
				var current_pen := profile.get_penetration(lifetime_timer)
				var effective := profile.get_effective_armor(plate.thickness, impact_normal, bullet_dir)
				var penetrated := current_pen > effective
				if penetrated:
					plate.apply_damage(profile.damage)
				return {hit_pos = hit_pos, penetrated = penetrated, handled = true}

	var damage_target := _find_damageable(body)
	if damage_target:
		damage_target.take_damage(profile.damage)
		return {hit_pos = hit_pos, penetrated = true, handled = true}

	if body is PhysicsBody2D:
		return {hit_pos = hit_pos, penetrated = false, handled = true}

	return {hit_pos = hit_pos, penetrated = false, handled = false}


static func _get_impact_normal(from: Vector2, to: Vector2, world: World2D) -> Vector2:
	var extended_to := from + (to - from) * RAY_MULTIPLIER
	var space_state := world.direct_space_state
	var query := PhysicsRayQueryParameters2D.create(from, extended_to)
	var result := space_state.intersect_ray(query)
	return result.normal if result else Vector2.ZERO


static func _find_damageable(body: Node2D) -> Node:
	if body.has_method("take_damage"):
		return body
	for child in body.get_children():
		if child.has_method("take_damage"):
			return child
	var parent := body.get_parent()
	if parent and parent.has_method("take_damage"):
		return parent
	return null
