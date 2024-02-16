extends Node

@export var highlightUtility : HighlightUtility

func toggle_hightlighting(toggle: bool):
	highlightUtility.toggle_highlighting(toggle)
