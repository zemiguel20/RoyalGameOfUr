extends CanvasLayer

## Signal that fires when we can safely return to the menu.
signal reload_scene

var is_paused := false
## Pausing is only allowed during the game, not when other menus are open.
var can_pause := false

func _ready():
	visible = false
	GameEvents.play_pressed.connect(_on_play_pressed)
	GameEvents.game_ended.connect(_on_game_ended)
	
	
func _on_play_pressed():
	can_pause = true
	
	
func _on_game_ended():
	can_pause = false
	

func _input(event):
	if can_pause and event is InputEventKey and event.is_action_pressed("game_pause"):
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
	_on_game_ended()
	GameEvents.back_to_main_menu_pressed.emit()
	## TODO: Remove when this signal is connected.
	get_tree().reload_current_scene()
	reload_scene.emit()


func _on_quit_pressed():
	get_tree().quit()
