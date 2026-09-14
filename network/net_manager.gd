extends Node

var network: NetworkCore
var spawner: NetSpawner
var interest: NetInterest
var timeline: NetTimeline
var ping: NetPing


func _ready() -> void:
	network = NetworkCore.new()
	spawner = NetSpawner.new()
	interest = NetInterest.new()
	ping = NetPing.new()
	timeline = NetTimeline.new()
	add_child(spawner)
	add_child(ping)
	add_child(timeline)
	add_child(interest)


func _process(delta: float) -> void:
	network.poll(delta)
