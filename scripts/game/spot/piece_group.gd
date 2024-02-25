class_name PieceGroup
extends Node3D

# NOTE: PLACEHOLDER
@export var _spots: Array[Spot]


func get_available_spot() -> Spot:
	var free_spots = _spots.filter(func(spot: Spot): return spot.piece == null)
	return free_spots.pick_random()


func get_all_spots() -> Array[Spot]:
	return _spots


func get_all_pieces() -> Array[Piece]:
	var pieces = []
	for spot in _spots:
		if spot.piece != null:
			pieces.append(spot.piece)
	return pieces
