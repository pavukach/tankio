class_name Health
extends Node

signal damaged(amount: float, new_health: float)
signal died()
signal health_changed(new_health: float)

@export var max_health: float = 100.0

var _current_health: float

var current_health: float:
	get: return _current_health

func _ready() -> void:
	_current_health = max_health
	health_changed.connect(_relay_health_changed)

func _relay_health_changed(_new_health: float) -> void:
	var tank := Tank.find_in(self)
	if tank:
		EventBus.health_updated.emit(tank.get_player_id(), _current_health, max_health)

func take_damage(amount: float) -> void:
	if not is_multiplayer_authority():
		return

	_current_health = max(0.0, _current_health - amount)
	damaged.emit(amount, _current_health)
	health_changed.emit(_current_health)
	rpc("sync_health", _current_health)

	if _current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	if not is_multiplayer_authority():
		return

	_current_health = min(max_health, _current_health + amount)
	health_changed.emit(_current_health)
	rpc("sync_health", _current_health)

@rpc("authority", "call_local", "reliable")
func sync_health(new_health: float) -> void:
	_current_health = new_health
	health_changed.emit(_current_health)