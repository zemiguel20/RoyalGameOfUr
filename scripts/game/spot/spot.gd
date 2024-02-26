class_name Spot
extends Node3D
## Base class for board spots


@export var is_rosette: bool = false
@export var give_extra_roll: bool = false
var piece: Piece = null


## Returns a position inside the spot where the piece can move to.
func sample_position() -> Vector3:
	return global_position
