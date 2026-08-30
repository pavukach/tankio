extends Node

var network: NetworkCore
var spawner: NetSpawner
var interest: NetInterest

func _ready() -> void:
	network = NetworkCore.new()
	spawner = NetSpawner.new(network, self)
	interest = NetInterest.new(network, spawner)


func _process(delta: float) -> void:
	network.poll(delta)
