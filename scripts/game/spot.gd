class_name Spot
extends Node3D
## A spot in the board. Has properties that define the spot characteristics in game rules.
## Used as a selection target for the moves. Also has highlight effects.


## Emitted when the mouse enters the spot.
signal mouse_entered
## Emitted when the mouse leaves the spot.
signal mouse_exited
## Emitted when the spot is clicked/selected.
signal selected

## If true, the pieces in this spot cannot get knocked out.
@export var is_safe: bool = false

## If true, if the player moves to this spot they should get an extra turn.
@export var give_extra_turn: bool = false

## If true, always allows stacking, independent of settings.
@export var force_allow_stack: bool = false

@onready var _highlighter := $Highlighter as MaterialHighlighterComponent


## Updates the highlight state. [param active] sets the active state of the effect, and
## [param color] sets the color of the effect.
func set_highlight(active : bool, color := Color.WHITE) -> void:
	if not _highlighter:
		return
	
	_highlighter.highlight_color = color
	_highlighter.active = active


func _on_mouse_entered():
	mouse_entered.emit()


func _on_mouse_exited():
	mouse_exited.emit()


func _on_input_event(_camera, event : InputEvent, _position, _normal, _shape_idx):
	if event.is_action_pressed("game_spot_selected"):
		selected.emit()
