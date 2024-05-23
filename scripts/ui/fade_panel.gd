class_name FadePanel
extends ColorRect

@export var _fading_duration = 2.5

var _delta: float

func _ready():
	visible = false


func _process(delta):
	_delta = delta
	

func fadeout():
	visible = true
	var duration = _fading_duration
	var old_color = color
	var new_color = old_color
	new_color.a = 1
	var time = 0 
	
	# Tween
	while time <= duration:
		time += _delta
		var next_color = old_color.lerp(new_color, time/duration)
		color = next_color
		await Engine.get_main_loop().process_frame
