extends CanvasLayer

var is_paused := false

func _ready():
	visible = false
	

func _input(event):
	if event is InputEventKey and event.is_action_pressed("game_pause"):
		toggle_pause()


func toggle_pause():
	is_paused = not is_paused
	Engine.time_scale = 0 if is_paused else 1
	visible = is_paused


func _on_continue_pressed():
	## Unless we already press the game pause button at the exact same frame, unpause the menu.
	if not Input.is_action_just_pressed("game_pause"):
		toggle_pause()


func _on_main_menu_pressed():
	toggle_pause()	
	GameEvents.back_to_main_menu_pressed.emit()


func _on_quit_pressed():
	get_tree().quit()
