class_name Highlight

enum Type {
	SELECTABLE,
	SELECTABLE_SPECIAL,
	HOVERED,
	SELECTED,
	POSITIVE,
	NEGATIVE,
	ROSETTE,
	KO,
	END,
	NEUTRAL,
}


const COLOR_MAP: Dictionary = {
	Type.SELECTABLE : Color("#00d8bdff"),
	Type.SELECTABLE_SPECIAL: Color.GOLD,
	Type.HOVERED : Color("#00ffdfff"),
	Type.SELECTED : Color("#009f8bff"),
	Type.POSITIVE : Color.GREEN,
	Type.NEGATIVE : Color.RED,
	Type.ROSETTE : Color.MEDIUM_PURPLE,
	Type.KO : Color.ORANGE,
	Type.END : Color.GREEN_YELLOW,
	Type.NEUTRAL : Color.GHOST_WHITE,
}


static func get_color(type: Type) -> Color:
	return COLOR_MAP[type]
