class_name HitEffect
extends Node2D

@export var penetrated: bool = false

var _max_radius: float = 40.0
var _start_color: Color
var _radius: float = 0.0
var _color: Color
var _timer: float = 0.0

func _ready() -> void:
	if penetrated:
		_start_color = Color(1.0, 0.0, 0.0, 0.8)
	else:
		_start_color = Color(0.0, 0.0, 0.0, 0.8)
	_color = _start_color

func _process(delta: float) -> void:
	_timer += delta
	var p: float = minf(_timer / 0.5, 1.0)
	_radius = lerpf(0.0, _max_radius, p)
	var a: float = lerpf(0.8, 0.0, p)
	_color = Color(_start_color.r, _start_color.g, _start_color.b, a)
	queue_redraw()
	if p >= 1.0:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, _color)
