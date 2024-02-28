class_name PieceGroup
extends Node3D


@export var _orientation: Orientation = HORIZONTAL
@export var _spawn_offset: float

var _spots: Array[Spot] = []


func setup(size: int) -> void:
	_spots.resize(size)
	var dir = Vector3.RIGHT if _orientation == HORIZONTAL else Vector3.UP
	for i in size:
		_spots[i] = Spot.new()
		add_child(_spots[i])
		_spots[i].global_position = global_position + i * dir * _spawn_offset


func get_available_spot() -> Spot:
	var free_spots = _spots.filter(func(spot: Spot): return spot.piece == null)
	if _orientation == HORIZONTAL:
		return free_spots.pick_random()
	else:
		return free_spots.front()


func get_all_spots() -> Array[Spot]:
	return _spots


func get_all_pieces() -> Array[Piece]:
	var pieces = [] as Array[Piece]
	for spot in _spots:
		if spot.piece != null:
			pieces.append(spot.piece)
	return pieces
