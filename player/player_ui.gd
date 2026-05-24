class_name PlayerUI
extends CanvasLayer

var _tank: Node2D
var _is_alive: bool = false

@onready var _selector := %TankSelector as VBoxContainer
@onready var _health_bar := %HealthBar as ProgressBar

func _ready():
	if multiplayer.is_server():
		return

	_health_bar.hide()
	_health_bar.value = 100
	_build_selector()

	EventBus.tank_spawned.connect(_on_tank_spawned)
	EventBus.tank_died.connect(_on_tank_died)
	EventBus.health_updated.connect(_on_health_updated)

func _build_selector():
	var spawner := get_node("../TankSpawner") as TankSpawner
	for i in spawner.tank_entries.size():
		var entry: TankEntry = spawner.tank_entries[i]
		var button := Button.new()
		button.text = entry.display_name
		button.pressed.connect(_on_tank_selected.bind(i))
		_selector.add_child(button)

func _on_tank_selected(index: int):
	_selector.hide()
	EventBus.request_spawn(index)

func _on_tank_spawned(tank_path: NodePath):
	_tank = get_node(tank_path) as Node2D
	if not _tank:
		return

	_is_alive = true
	_selector.hide()
	_health_bar.max_value = 100
	_health_bar.value = 100
	_health_bar.show()

func _on_tank_died():
	_is_alive = false
	_tank = null
	_health_bar.hide()
	_selector.show()

func _on_health_updated(tank_id: int, current_health: float, max_health: float):
	if not _tank or tank_id != _tank.get_player_id():
		return
	_health_bar.max_value = max_health
	_health_bar.value = current_health
