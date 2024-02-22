class_name Board
extends Node
## Manages the state of the board. It stores in which spot the pieces of each player are.
## It allows queries to the state of the board, and also moves the pieces.


## Initialize the board
func setup():
	# TODO: implement
	pass


## Returns the list of pieces of the given [param player_id] that can be moved in [param roll] steps.
## If the list is empty, then the player has no possible moves.
func legal_moves(player_id: int, roll: int) -> Array[Piece]:
	var moves = []
	
	var pieces = _get_player_pieces(player_id)
	for piece in pieces:
		if _is_moving_within_bounds(piece, roll):
			var landing_spot = _get_landing_spot(piece, roll)
			var other_player_id = General.get_other_player_id(player_id)
			if not _is_occupied_by_player(landing_spot, player_id) \
				or not (_is_occupied_by_player(landing_spot, other_player_id) and _is_rosette(landing_spot)):
					moves.append(piece)
	
	return moves


## Moves [param piece] a number of steps equal to [param roll]. Returns a feedback code depending on the result on the move.
## [br]
## 0 - Normal/Nothing [br]
## 1 - Gets extra roll [br]
## 2 - Won the game [br]
func move(piece: Piece, roll: int) -> int:
	var movement_path = _get_movement_path(piece, roll)
	await piece.move(movement_path)
	var landing_spot = _get_landing_spot(piece, roll)
	_update_piece_placement(piece, landing_spot)
	
	var player_id = _get_player_id(piece)
	if _player_won(player_id):
		return 2
	elif _has_extra_roll(landing_spot):
		return 1
	else:
		return 0


func _get_player_pieces(player_id: int) -> Array[Piece]:
	# TODO: implement
	return []


# Roll cannot be higher than steps needed to get to last spot
func  _is_moving_within_bounds(piece: Piece, roll: int) -> bool:
	# TODO: implement
	return false


func  _get_landing_spot(piece: Piece, roll: int) -> Spot:
	# TODO: implement
	return null


func _is_occupied_by_player(spot: Spot, player_id: int) -> bool:
	# TODO: implement
	return false


func _is_rosette(spot: Spot) -> bool:
	# TODO: implement
	return false


func _get_movement_path(piece: Piece, roll: int) -> Array[Vector3]:
	# TODO: implement
	return []


func _update_piece_placement(piece: Piece, landing_spot: Spot):
	# TODO: implement
	pass


func _get_player_id(piece: Piece) -> int:
	# TODO: implement
	return General.PlayerID.ONE


func _player_won(player_id) -> bool:
	# TODO: implement
	return false


func _has_extra_roll(landing_spot: Spot) -> bool:
	# TODO: implement
	return false
