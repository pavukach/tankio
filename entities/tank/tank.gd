class_name Tank
extends Node2D

@export var hull: HullMovement
@export var turret: TurretMovement
@export var shooter: Shooter
@export var input_reader: InputReader
@export var health: Health

@export_range(1, 500) var max_health: float = 100.0

var _health_component: Health

static func find_in(node: Node) -> Tank:
	var current := node.get_parent()
	while current:
		if current is Tank:
			return current
		current = current.get_parent()
	return null

func get_player_id() -> int:
	return int(name)

func _ready():
	if is_multiplayer_authority():
		_setup_health()

func _setup_health():
	if health:
		_health_component = health
		health.max_health = max_health
	else:
		_health_component = Health.new()
		_health_component.max_health = max_health
		add_child(_health_component)

func _process(_delta: float):
	if not is_multiplayer_authority():
		return

	if not input_reader:
		return

	if hull:
		hull.input = input_reader
	if turret:
		turret.input = input_reader
	if shooter:
		shooter.input = input_reader

func get_health() -> Health:
	if health:
		return health
	return _health_component

func take_damage(amount: float) -> void:
	var h := get_health()
	if h:
		h.take_damage(amount)

@rpc("authority", "call_local", "reliable")
func despawn():
	if get_parent():
		get_parent().remove_child(self)
	queue_free()