class_name BarBorder
extends Panel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = BarStyle.PANEL_BG_COLOR
	style.border_color = BarStyle.BORDER_COLOR
	style.set_border_width_all(BarStyle.PANEL_BORDER_WIDTH)
	add_theme_stylebox_override("panel", style)