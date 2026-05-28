class_name HealthBarUI
extends ProgressBar

func _ready() -> void:
	_setup_background()
	hide()

func update_value(current: float, max_value: float) -> void:
	self.max_value = max_value
	value = current
	_update_color()
	show()

func _setup_background() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.0, 0.0, 0.0, 0.3)
	bg.border_color = Color(0.4, 0.4, 0.4)
	bg.set_border_width_all(3)
	add_theme_stylebox_override("background", bg)

func _update_color() -> void:
	var ratio := value / max_value if max_value > 0 else 0.0
	_set_fill_color(_health_color(ratio))

static func _health_color(ratio: float) -> Color:
	if ratio > 0.5:
		var t := (ratio - 0.5) * 2.0
		return Color(1.0 - t, 1.0, 0.0)
	else:
		var t := ratio * 2.0
		return Color(1.0, t, 0.0)

func _set_fill_color(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	add_theme_stylebox_override("fill", style)
