class_name Spot
extends Node3D
## A spot in the board. Has properties that define the spot characteristics in game rules.
## Used as a selection target for the moves. Also has highlight effects.


## If true, the pieces in this spot cannot get knocked out.
@export var is_safe: bool = false

## If true, if the player moves to this spot they should get an extra turn.
@export var give_extra_turn: bool = false

## If true, always allows stacking, independent of settings.
@export var force_allow_stack: bool = false

var highlight: MaterialHighlight
var input: SelectionInputReader


func _ready():
	highlight = get_node(get_meta("highlight")) as MaterialHighlight
	input = get_node(get_meta("input")) as SelectionInputReader
