class_name DialogueMenuController
extends CanvasLayer

enum Menu {
	LookAround = 0,
}

@onready var _look_around_panel := $MarginContainer as Control

func toggle_menu(menu: Menu, toggle: bool):
	match menu:
		Menu.LookAround:
			_toggle_look_around_panel(toggle)
		_:
			push_warning("DialogueMenuController: Menu %s has not been implemented" % menu)

func _toggle_look_around_panel(toggle: bool):
	_look_around_panel.visible = toggle
