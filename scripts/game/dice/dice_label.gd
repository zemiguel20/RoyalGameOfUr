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
var _target_color
var _tween_color

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
func play_effect(duration: float):
	visible = true
	
	_tween_color = create_tween()
	_tween_color.bind_node(self)
	_tween_color.tween_property(self, "modulate", _target_color, duration/4)
	_tween_color.tween_interval(duration/2)
	_tween_color.tween_property(self, "modulate", _default_color, duration/4)
	await _tween_color.finished


func _on_dice_roll_finished(value: int):
	text = "%s" % value
	_target_color = _color_moves
	# HACK: Possibly wait for no moves signal.
	await get_tree().create_timer(0.1).timeout	
	play_effect(_effect_duration)	


func _on_no_moves():
	_target_color = _color_no_moves
