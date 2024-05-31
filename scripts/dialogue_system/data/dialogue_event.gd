class_name ShowMenuEntry
extends DialogueEntry

## Another problem: How do we reference the menu?
func execute(dialogue_menu_controller: DialogueMenuController):
	dialogue_menu_controller.toggle_look_around_panel(true)
	
	## This condition could be changed to wait until the person is holding right mouse.
	await dialogue_menu_controller.get_tree().create_timer(3).timeout
	
	dialogue_menu_controller.toggle_look_around_panel(false)
