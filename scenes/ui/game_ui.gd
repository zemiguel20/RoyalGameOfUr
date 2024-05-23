extends Node

## When someone wins the game, we will fadeout and then reload the scene.
signal fadeout_finished

@onready var _fade_panel = $Fade_Panel as FadePanel
@onready var _pause_menu = $Pause_Menu as PauseMenu


func _input(event):
	if event.is_action_pressed("game_pause"):
		_pause_menu.toggle()
	

func _on_game_ended():
	await _fade_panel.fadeout()
	fadeout_finished.emit()
