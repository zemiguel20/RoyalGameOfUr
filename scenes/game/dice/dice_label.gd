extends Label3D

@export_color_no_alpha var color_moves: Color
@export_color_no_alpha var color_no_moves: Color
@export var effect_duration: float
@export var effect_curve: Curve

var _default_color
var _delta

func _ready():
	_default_color = modulate
	visible = false
	color_moves.a = 1.0
	color_no_moves.a = 1.0


func _process(delta):
	_delta = delta


func play_effect(new_color: Color, duration: float):
	visible = true
	var old_color = new_color
	old_color.a = 0
	modulate = old_color
	var time = 0 
	
	while time <= duration:
		time += _delta
		var next_color = old_color.lerp(new_color, effect_curve.sample(time/duration))
		modulate = next_color
		await Engine.get_main_loop().process_frame
		
	visible = false
	

func _on_dice_die_stopped(value: int):
	pass

func _on_dice_roll_finished(value: int):
	text = "%s" % value
	if value == 0:
		play_effect(color_no_moves, effect_duration)
	else:
		play_effect(color_moves, effect_duration)		
