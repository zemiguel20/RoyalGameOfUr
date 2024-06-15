extends CanvasLayer

## Signal that fires when we can safely return to the menu.
signal on_can_return_safely

var can_return_safely: bool
var is_paused := false
## Pausing is only allowed during the game, not when other menus are open.
var can_pause := false

func _ready():
	visible = false
	GameEvents.play_pressed.connect(_on_play_pressed)
	GameEvents.game_ended.connect(_on_game_ended)
	
	
func _on_play_pressed():
	can_pause = true
	can_return_safely = true
	
	#GameEvents.move_executed.connect(_on_phase_ended)
	#GameEvents.rolled.connect(_on_phase_ended)
	#GameEvents.opponent_action_prevented.connect(_on_phase_ended)
	#GameEvents.new_turn_started.connect(_on_danger_started)
	#GameEvents.roll_sequence_finished.connect(_on_danger_started)
	#GameEvents.intro_sequence_finished.connect(_on_danger_started)
	#GameEvents.opponent_action_resumed.connect(_on_phase_ended)	
	
	
func _on_game_ended():
	can_pause = false
	#if GameEvents.move_executed.is_connected(_on_phase_ended):
		#GameEvents.move_executed.disconnect(_on_phase_ended)
	#if GameEvents.roll_sequence_finished.is_connected(_on_phase_ended):
		#GameEvents.roll_sequence_finished.disconnect(_on_phase_ended)
	
	
### Triggered when a player just finished a roll or move.
#func _on_phase_ended():
	#can_return_safely = true
	#on_can_return_safely.emit()
	#
	#
#func _on_danger_started():
	#can_return_safely = false
	

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
	if not can_return_safely:
		await on_can_return_safely
	_on_game_ended()
	GameEvents.back_to_main_menu_pressed.emit()


func _on_quit_pressed():
	get_tree().quit()
