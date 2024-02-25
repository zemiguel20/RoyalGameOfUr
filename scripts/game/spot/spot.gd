class_name Spot
extends Node3D
## Base class for board spots


@export var is_rosette: bool = false
@export var give_extra_roll: bool = false
@export var _piece_place: Node3D
var piece: Piece = null



## Returns a position inside the spot where the piece can move to.
func sample_position() -> Vector3:
	return _piece_place.global_position
