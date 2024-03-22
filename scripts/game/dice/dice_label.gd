class_name DiceOutcomeLabel
extends Label3D

@export_color_no_alpha var _color_moves: Color
@export_color_no_alpha var _color_no_moves: Color
@export var _effect_duration: float
## Curve defining the flow of the color transition effect on the label.
## Y = 0 will be the original color of the label, Y = 1 will be the new color (e.g. red when no moves)
@export var _effect_curve: Curve

var _default_color
var _delta

func _ready():
	_default_color = modulate
	visible = false
	_color_moves.a = 1.0
	_color_no_moves.a = 1.0


func _process(delta):
	_delta = delta


## Example of a simple highlighting effect for the dice label.
## In this method, we lerp from the label'original color to a new color, following a curve.
## The flow of this animation is defined by [param _effect_curve] 
func play_effect(new_color: Color, duration: float):
	visible = true
	var old_color = modulate
	var time = 0 
	
	while time <= duration:
		time += _delta
		var next_color = old_color.lerp(new_color, _effect_curve.sample(time/duration))
		modulate = next_color
		await Engine.get_main_loop().process_frame
		
	visible = false
	

func _on_dice_roll_finished(value: int):
	text = "%s" % value
	if value == 0:
		play_effect(_color_no_moves, _effect_duration)
	else:
		play_effect(_color_moves, _effect_duration)		
