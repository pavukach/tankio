class_name AutoloadNetworkObject
extends NetworkObject


func _ready() -> void:
	network_id = Network.acquire_id()
	Network.add_entity(network_id, self)
	super._ready()
