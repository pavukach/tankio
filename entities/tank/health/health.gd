class_name Health
extends Node

signal damaged(amount: float, new_health: float)
signal died()
signal health_changed(new_health: float)

@export var max_health: float = 100.0

var _net: NetNode
var net_health: NetVar

var _current_health: float

var current_health: float:
	get: return _current_health

func _ready() -> void:
	_net = owner as NetNode
	_current_health = max_health
	net_health = NetVar.new(max_health, ByteData.Type.FLOAT)
	_net.register_reliable_var(net_health)
	net_health.changed.connect(_on_net_health)
	health_changed.connect(_relay_health_changed)

func _on_net_health() -> void:
	_current_health = net_health.get_value()
	health_changed.emit(_current_health)

func _relay_health_changed(_new_health: float) -> void:
	LocalBus.health_updated.emit(_net.owner_id, _current_health, max_health)

func take_damage(amount: float) -> void:
	if not NetManager.network.is_server():
		return

	_current_health = max(0.0, _current_health - amount)
	damaged.emit(amount, _current_health)
	health_changed.emit(_current_health)
	net_health.set_value(_current_health)

	if _current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	if not NetManager.network.is_server():
		return

	_current_health = min(max_health, _current_health + amount)
	health_changed.emit(_current_health)
	net_health.set_value(_current_health)