class_name PauseScreen extends CanvasLayer


@export var test: bool = false

var is_paused := false
## Pausing is only allowed during the game, not when other menus are open.
var can_pause := false


func _ready():
	visible = false
	GameEvents.game_started.connect(_on_game_started)
	GameEvents.game_ended.connect(_on_game_ended)
	
	can_pause = test


func _input(event):
	if can_pause and event is InputEventKey and event.is_action_pressed("game_pause"):
		toggle_pause()


func _on_game_started():
	can_pause = true
	
	
func _on_game_ended():
	can_pause = false


func toggle_pause():
	is_paused = not is_paused
	Engine.time_scale = 0 if is_paused else 1
	visible = is_paused


func _on_continue_pressed():
	toggle_pause()


func _on_main_menu_pressed():
	toggle_pause()
	_on_game_ended()
	GameEvents.back_to_main_menu_pressed.emit()


func _on_quit_pressed():
	get_tree().quit()
