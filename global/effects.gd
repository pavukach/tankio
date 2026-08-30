extends Node

func spawn_hit_effect(pos: Vector2, penetrated: bool) -> void:
	var effect := preload("res://entities/projectile/hit_effect.tscn").instantiate()
	effect.position = pos
	effect.penetrated = penetrated
	get_tree().root.add_child(effect)