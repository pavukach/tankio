class_name InterestTarget
extends Area2D

var entity_id: int


func _ready():
	var net_obj: NetworkObject = owner as NetworkObject
	if net_obj == null:
		net_obj = get_parent() as NetworkObject
	entity_id = net_obj.network_id
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()

	shape.radius = 32.0
	collider.shape = shape

	add_child(collider)
	collision_layer = NetInterest.INTEREST_LAYER
	collision_mask = 1 << (NetInterest.INTEREST_LAYER - 1)
	monitoring = true
	monitorable = true
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	if not Network.is_server():
		return
	if area is not InterestZone:
		return

	var zone: InterestZone = area
	if zone.type != InterestZone.Type.SPAWN:
		return

	NetInterest.start_tracking(entity_id, zone.player_id)

func _on_area_exited(area: Area2D) -> void:
	if not Network.is_server():
		return
	if area is not InterestZone:
		return

	var zone: InterestZone = area
	if zone.type != InterestZone.Type.DESPAWN:
		return

	NetInterest.stop_tracking(entity_id, zone.player_id)
