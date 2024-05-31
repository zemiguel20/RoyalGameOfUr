class_name DialogueMenuController
extends CanvasLayer

@onready var _look_around_panel := $MarginContainer as Control

func toggle_look_around_panel(toggle: bool):
	_look_around_panel.visible = toggle
