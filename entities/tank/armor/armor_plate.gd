class_name ArmorPlate
extends CollisionShape2D

@export var thickness: float = 50.0

func apply_damage(amount: float) -> void:
	%Health.take_damage(amount)
