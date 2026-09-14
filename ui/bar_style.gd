class_name BarStyle

const BG_COLOR := Color(0.0, 0.0, 0.0, 0.3)
const PANEL_BG_COLOR := Color(0.0, 0.0, 0.0, 0.0)
const BORDER_COLOR := Color(0.4, 0.4, 0.4)
const FILL_BORDER_WIDTH := 3
const PANEL_BORDER_WIDTH := 2
const MID_RATIO := 0.5
const RATIO_SCALE := 2.0

static func gradient_color(ratio: float) -> Color:
	if ratio > MID_RATIO:
		var t := (ratio - MID_RATIO) * RATIO_SCALE
		return Color(1.0 - t, 1.0, 0.0)
	else:
		var t := ratio * RATIO_SCALE
		return Color(1.0, t, 0.0)