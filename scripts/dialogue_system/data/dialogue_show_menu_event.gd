class_name ShowMenuEntry
extends DialogueEntry

@export var menu_to_display: DialogueMenuController.Menu
@export var wait_time: float = 3

func execute(dialogue_menu_controller: DialogueMenuController):
	dialogue_menu_controller.toggle_menu(menu_to_display, true)
	
	## This condition could be changed to wait until the person is holding right mouse.
	await dialogue_menu_controller.get_tree().create_timer(wait_time).timeout
	
	dialogue_menu_controller.toggle_menu(menu_to_display, false)
