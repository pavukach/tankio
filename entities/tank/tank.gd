class_name Tank
extends NetNode

@export var hull: HullMovement
@export var turret: TurretMovement
@export var shooter: Shooter
@export var health: Health

@export_range(1, 500) var max_health: float = 100.0

var _health_component: Health

func _ready():
	super._ready()
	if NetManager.network.is_server():
		_setup_health()
		hull.add_child(InterestTarget.new(network_id))

func attach_input(reader: InputReader) -> void:
	if hull:
		hull.input = reader
	if turret:
		turret.input = reader
	if shooter:
		shooter.input = reader

func _setup_health():
	if health:
		_health_component = health
		health.max_health = max_health
	else:
		_health_component = Health.new()
		_health_component.max_health = max_health
		add_child(_health_component)

func get_health() -> Health:
	if health:
		return health
	return _health_component

func take_damage(amount: float) -> void:
	var h := get_health()
	if h:
		h.take_damage(amount)