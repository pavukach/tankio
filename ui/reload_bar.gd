class_name ReloadBarUI
extends ProgressBar

const FILL_SCALE := 100.0

var _reload_time: float = 0.0
var _reload_elapsed: float = 0.0
var _is_reloading: bool = false

func _ready() -> void:
	_setup_background()
	hide()

func _setup_background() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = BarStyle.BG_COLOR
	bg.border_color = BarStyle.BORDER_COLOR
	bg.set_border_width_all(BarStyle.FILL_BORDER_WIDTH)
	add_theme_stylebox_override("background", bg)

func _process(delta: float) -> void:
	if not _is_reloading:
		return
	_reload_elapsed += delta
	var progress: float = min(_reload_elapsed / _reload_time, 1.0)
	value = progress * FILL_SCALE
	_update_color(progress)
	if _reload_elapsed >= _reload_time:
		_is_reloading = false
		hide()

func start_reload(time: float) -> void:
	_reload_time = time
	_reload_elapsed = 0.0
	_is_reloading = true
	max_value = FILL_SCALE
	value = 0
	show()
	_set_fill_color(Color(1.0, 0.0, 0.0))

func stop() -> void:
	_is_reloading = false
	hide()

func _update_color(ratio: float) -> void:
	_set_fill_color(BarStyle.gradient_color(ratio))

func _set_fill_color(color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	add_theme_stylebox_override("fill", style)