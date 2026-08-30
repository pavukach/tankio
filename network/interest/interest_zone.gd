class_name InterestZone
extends Area2D

enum Type {
	SPAWN,
	DESPAWN
}

var player_id: int
var size: int
var type: Type

func _init(p_player_id: int, p_size: int, p_type: Type) -> void:
	player_id = p_player_id
	size = p_size
	type = p_type

func _ready():
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()

	shape.radius = size
	collider.shape = shape

	add_child(collider)
	collision_layer = NetInterest.INTEREST_LAYER
	collision_mask = 1 << (NetInterest.INTEREST_LAYER - 1)
	monitoring = true
	monitorable = true
