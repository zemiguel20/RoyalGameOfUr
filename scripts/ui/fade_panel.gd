extends Node

## When someone wins the game, we will fadeout and then reload the scene.
signal fadeout_finished

@export var _fading_duration = 2.5
@onready var _fade_panel = $Fade_Panel as ColorRect

var _delta: float

func _ready():
	_fade_panel.visible = false


func _process(delta):
	_delta = delta


func _on_game_ended():
	_fade_panel.visible = true
	await _fadeout(_fading_duration)
	fadeout_finished.emit()
	

func _fadeout(duration: float):
	var old_color = _fade_panel.color
	var new_color = old_color
	new_color.a = 1
	var time = 0 
	
	# Tween
	while time <= duration:
		time += _delta
		var next_color = old_color.lerp(new_color, time/duration)
		_fade_panel.color = next_color
		await Engine.get_main_loop().process_frame
