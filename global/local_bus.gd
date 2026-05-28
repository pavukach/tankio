extends Node

signal health_updated(tank_id: int, current_health: float, max_health: float)
signal reload_started(tank_id: int, reload_time: float)
signal connected()
