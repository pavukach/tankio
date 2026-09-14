class_name HitEffect
extends Node2D

const MAX_RADIUS := 40.0
const DURATION := 0.5
const START_ALPHA := 0.8
const PENETRATED_COLOR := Color(1.0, 0.0, 0.0, 0.8)
const BLOCKED_COLOR := Color(0.0, 0.0, 0.0, 0.8)

@export var penetrated: bool = false

var _start_color: Color
var _radius: float = 0.0
var _color: Color
var _timer: float = 0.0

func _ready() -> void:
	_start_color = PENETRATED_COLOR if penetrated else BLOCKED_COLOR
	_color = _start_color

func _process(delta: float) -> void:
	_timer += delta
	var p: float = minf(_timer / DURATION, 1.0)
	_radius = lerpf(0.0, MAX_RADIUS, p)
	var a: float = lerpf(START_ALPHA, 0.0, p)
	_color = Color(_start_color.r, _start_color.g, _start_color.b, a)
	queue_redraw()
	if p >= 1.0:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, _color)