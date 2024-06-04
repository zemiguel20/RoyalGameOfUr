class_name ShowMenuEntry
extends DialogueEntry

@export var menu_to_display: DialogueMenuController.Menu
@export var _input_action: String
@export var _wait_time: float = 0

func execute(dialogue_menu_controller: DialogueMenuController):
	dialogue_menu_controller.toggle_menu(menu_to_display, true)
	await await_conditions(dialogue_menu_controller)
	dialogue_menu_controller.toggle_menu(menu_to_display, false)


## Await the two optional conditions: Action press and waiting
func await_conditions(node):
	if _input_action != null and _input_action != "":
		while not Input.is_action_just_pressed(_input_action):
			## Wait a frame when the action is not pressed.
			await Engine.get_main_loop().process_frame
	
	await node.get_tree().create_timer(_wait_time).timeout
	
