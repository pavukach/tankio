class_name Tank
extends NetNode

@export var hull: HullMovement
@export var turret: TurretMovement
@export var shooter: Shooter
@export var health: Health

@export_range(1, 500) var max_health: float = 100.0

func _ready():
	super._ready()
	if NetManager.network.is_server():
		health.max_health = max_health
		hull.add_child(InterestTarget.new(network_id))

func attach_input(reader: InputReader) -> void:
	hull.input = reader
	turret.input = reader
	shooter.input = reader

func get_health() -> Health:
	return health

func take_damage(amount: float) -> void:
	health.take_damage(amount)