class_name BarBorder
extends Panel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.border_color = Color(0.4, 0.4, 0.4)
	style.set_border_width_all(2)
	add_theme_stylebox_override("panel", style)
