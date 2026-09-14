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
	bg.bg_color = BarStyle.BG_COLOR
	bg.border_color = BarStyle.BORDER_COLOR
	bg.set_border_width_all(BarStyle.FILL_BORDER_WIDTH)
	add_theme_stylebox_override("background", bg)

func _update_color() -> void:
	var ratio := value / max_value if max_value > 0 else 0.0
	_set_fill_color(BarStyle.gradient_color(ratio))

func _set_fill_color(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	add_theme_stylebox_override("fill", style)