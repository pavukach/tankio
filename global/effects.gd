extends Node

func net_hit(x: float, y: float, penetrated: int) -> void:
	spawn_hit_effect(Vector2(x, y), penetrated != 0)


func spawn_hit_effect(pos: Vector2, penetrated: bool) -> void:
	var effect := preload("res://entities/projectile/hit_effect.tscn").instantiate()
	effect.position = pos
	effect.penetrated = penetrated
	get_tree().root.add_child(effect)