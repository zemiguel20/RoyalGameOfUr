class_name Spot
extends Node3D
## Base class for board spots


## Returns a position inside the spot where the piece can move to.
func sample_position() -> Vector3:
	return Vector3.ZERO
