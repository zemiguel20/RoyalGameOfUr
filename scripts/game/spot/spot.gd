class_name Spot
extends Node3D
## Base class for board spots


@export var is_safe: bool = false
@export var give_extra_roll: bool = false
@export var _highlighter: MaterialHighlighter
var piece: Piece = null


## Returns a position inside the spot where the piece can move to.
func sample_position() -> Vector3:
	return global_position


func highlight() -> void:
	if _highlighter != null:
		_highlighter.highlight()


func dehighlight() -> void:
	if _highlighter != null:
		_highlighter.dehighlight()
