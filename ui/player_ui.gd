class_name PlayerUI
extends CanvasLayer

const AUTOSPAWN_DELAY := 1.5

var _tank: Tank

@onready var _selector := %TankSelector
@onready var _health_bar := %HealthBar
@onready var _reload_bar := %ReloadBar

func _ready():
	LocalBus.connected.connect(initialize)

func initialize():
	_selector.tank_selected.connect(_on_tank_selected)
	_selector.build(TankSpawner)

	var ctx := _local_context()
	ctx.bus.tank_spawned.connect(_on_tank_spawned)
	ctx.bus.tank_died.connect(_on_tank_died)
	LocalBus.health_updated.connect(_on_health_updated)
	LocalBus.reload_started.connect(_on_reload_started)
	LocalBus.local_player_spawned.connect(_on_local_player_spawned)
	if OS.get_environment("TANKIO_AUTOSPAWN") == "1":
		get_tree().create_timer(AUTOSPAWN_DELAY).timeout.connect(_on_tank_selected.bind(0))


func _local_context() -> PlayerContext:
	return NetManager.network.get_entity(NetworkCore.CONTEXT_ENTITY) as PlayerContext

func _on_tank_selected(index: int):
	_selector.hide()
	var ctx := _local_context()
	ctx.bus.request_spawn(index)

func _on_tank_spawned(_tank_path: NodePath):
	_selector.hide()


func _on_local_player_spawned(tank: Tank):
	_tank = tank
	_selector.hide()
	var tank_health := tank.get_health()
	_health_bar.update_value(tank_health.current_health, tank_health.max_health)

func _on_tank_died():
	_tank = null
	_reload_bar.stop()
	_health_bar.hide()
	_selector.show()
	print("Tank died")

func _on_health_updated(tank_id: int, current_health: float, max_health: float):
	if not _tank or tank_id != _tank.owner_id:
		return
	_health_bar.update_value(current_health, max_health)

func _on_reload_started(tank_id: int, reload_time: float):
	if not _tank or tank_id != _tank.owner_id:
		return
	_reload_bar.start_reload(reload_time)