class_name PlayerUI
extends CanvasLayer

var _tank: Node2D

@onready var _selector := %TankSelector
@onready var _health_bar := %HealthBar
@onready var _reload_bar := %ReloadBar

func _ready():
	LocalBus.connected.connect(initialize)

func initialize():
	_selector.tank_selected.connect(_on_tank_selected)
	_selector.build(TankSpawner)

	NetworkBus.tank_spawned.connect(_on_tank_spawned)
	NetworkBus.tank_died.connect(_on_tank_died)
	LocalBus.health_updated.connect(_on_health_updated)
	LocalBus.reload_started.connect(_on_reload_started)

func _on_tank_selected(index: int):
	_selector.hide()
	NetworkBus.request_spawn(index)

func _on_tank_spawned(tank_path: NodePath):
	if _tank and is_instance_valid(_tank):
		_tank.queue_free()
	_tank = get_node(tank_path) as Node2D
	if not _tank:
		return
	_selector.hide()
	_health_bar.update_value(100, 100)

func _on_tank_died():
	_tank = null
	_reload_bar.stop()
	_health_bar.hide()
	_selector.show()
	print("Tank died")

func _on_health_updated(tank_id: int, current_health: float, max_health: float):
	if not _tank or tank_id != _tank.get_player_id():
		return
	_health_bar.update_value(current_health, max_health)

func _on_reload_started(tank_id: int, reload_time: float):
	if not _tank or tank_id != _tank.get_player_id():
		return
	_reload_bar.start_reload(reload_time)
