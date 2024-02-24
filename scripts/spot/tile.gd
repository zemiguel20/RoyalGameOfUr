class_name Tile
extends Spot


var piece: Piece = null
@onready var _piece_place: Node3D = $PiecePlace


func sample_position() -> Vector3:
	return _piece_place.global_position
