class_name Board
extends Node
## Manages the state of the board. It stores in which spot the pieces of each player are.
## It allows queries to the state of the board, and also moves the pieces.


@export var _pieces: Array[Piece]
@export var _p1_start_area: PieceGroup
@export var _p1_end_area: PieceGroup
@export var _p1_track: Array[Spot]
@export var _p2_start_area: PieceGroup
@export var _p2_end_area: PieceGroup
@export var _p2_track: Array[Spot]

# Key = player id, Value = [start_area, track, end_area]
var _p_track: Dictionary = {}

## Initialize the board
func setup():
	_p_track[General.PlayerID.ONE] = [_p1_start_area, _p1_track, _p1_end_area]
	_p_track[General.PlayerID.TWO] = [_p2_start_area, _p2_track, _p2_end_area]
	
	for piece in _pieces:
		var start_spot = _get_start_area(piece.player).get_available_spot()
		move(piece, start_spot)


## Moves [param piece] to [param landing_spot]. Moves opponent piece to starting area if it gets knocked out.
func move(piece: Piece, landing_spot: Spot) -> void:
	var movement_path = _get_movement_path(piece, landing_spot)
	await piece.move(movement_path)
	
	var opponent_id = General.get_other_player_id(piece.player)
	if is_occupied_by_player(landing_spot, opponent_id):
		# Move to start
		var start_area = _p1_start_area if landing_spot.piece.player == 1 else _p2_start_area
		var start_spot = start_area.get_available_spot()
		await move(landing_spot.piece, start_spot)
	
	landing_spot.piece = piece


func get_pieces(player_id: int) -> Array[Piece]:
	return _pieces.filter(func(piece: Piece): return piece.player == player_id)


func  get_landing_spot(piece: Piece, roll: int) -> Spot:
	var start_area = _get_start_area(piece.player)
	var end_area = _get_end_area(piece.player)
	var track = _get_track(piece.player)
	
	# If in start area, return spot in track equal to roll
	if start_area.get_all_pieces().has(piece):
		return track[roll - 1]
	
	# If in middle of the track, check which spot to move to
	for spot in track:
		if spot.piece == piece:
			var index = track.find(spot)
			var target_index = index + roll
			if target_index < track.size():
				return track[target_index]
			elif target_index == track.size():
				return end_area.get_available_spot()
			else:
				return null # Out of bounds, needs precise roll
	# If in end area, return null as piece cannot move
	return null


func is_occupied_by_player(spot: Spot, player_id: int) -> bool:
	return spot.piece != null and spot.piece.player == player_id


func is_winner(player_id: int) -> bool:
	var finished_pieces = (_p_track[player_id][2] as PieceGroup).get_all_pieces()
	var player_pieces = get_pieces(player_id)
	return finished_pieces.size() == player_pieces.size()


func _get_movement_path(piece: Piece, landing_spot: Spot) -> Array[Vector3]:
	# TODO: implement
	return [landing_spot.sample_position()]


func _get_start_area(player_id: int) -> PieceGroup:
	return _p_track[player_id][0]


func _get_track(player_id: int) -> Array[Spot]:
	return _p_track[player_id][1]


func _get_end_area(player_id: int) -> PieceGroup:
	return _p_track[player_id][2]
