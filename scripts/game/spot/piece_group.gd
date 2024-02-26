class_name PieceGroup
extends Node3D


var _spots: Array[Spot] = []


func setup(size: int) -> void:
	_spots.resize(size)
	for i in size:
		_spots[i] = Spot.new()
		add_child(_spots[i])
		_spots[i].global_position = global_position + i * Vector3.RIGHT * 1.5 # TODO: implement actual offset


func get_available_spot() -> Spot:
	var free_spots = _spots.filter(func(spot: Spot): return spot.piece == null)
	return free_spots.pick_random()


func get_all_spots() -> Array[Spot]:
	return _spots


func get_all_pieces() -> Array[Piece]:
	var pieces = [] as Array[Piece]
	for spot in _spots:
		if spot.piece != null:
			pieces.append(spot.piece)
	return pieces
