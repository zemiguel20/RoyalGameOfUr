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
	
	# Init start and end zones
	for player in _p_track:
		var	zone_size = get_pieces(player).size()
		_get_start_area(player).setup(zone_size)
		_get_end_area(player).setup(zone_size)
	
	# Init pieces
	for piece in _pieces:
		var start_spot = _get_start_area(piece.player).get_available_spot()
		piece.global_position = start_spot.sample_position()
		start_spot.piece = piece
		piece.disable_selection()


## Moves [param piece] to [param landing_spot]. Moves opponent piece to starting area if it gets knocked out.
func move(piece: Piece, landing_spot: Spot) -> void:
	var movement_path = _get_movement_path(piece, landing_spot)
	await piece.move(movement_path)
	
	var opponent_id = General.get_other_player_id(piece.player)
	if is_occupied_by_player(landing_spot, opponent_id):
		# Move opponent to start
		var start_spot = _get_start_area(opponent_id).get_available_spot()
		await move(landing_spot.piece, start_spot)
	
	# Update spot info
	get_current_spot(piece).piece = null
	landing_spot.piece = piece


## Returns the list of all pieces of the given [param player].
func get_pieces(player: int) -> Array[Piece]:
	return _pieces.filter(func(piece: Piece): return piece.player == player)


## Returns the spot the [param piece] will land on with the given [param roll].
## Returns [code]null[/code] if landing outside board bounds, that is, past the last spot of the track.
func  get_landing_spot(piece: Piece, roll: int) -> Spot:
	var start_area = _get_start_area(piece.player)
	var end_area = _get_end_area(piece.player)
	var track = _get_track(piece.player)
	
	# If in start area, return spot in track equal to roll
	if start_area.get_all_pieces().has(piece):
		if roll <= track.size():
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


## Returns [code]true[/code] if the [param spot] is occupied by a piece of the given [param player].
## Otherwise return  [code]false[/code].
func is_occupied_by_player(spot: Spot, player: int) -> bool:
	return spot.piece != null and spot.piece.player == player


## Returns [code]true[/code] if the [param player] has all of its pieces in the end area.
## Otherwise return  [code]false[/code].
func is_winner(player: int) -> bool:
	var finished_pieces = (_p_track[player][2] as PieceGroup).get_all_pieces()
	var player_pieces = get_pieces(player)
	return finished_pieces.size() == player_pieces.size()


## Returns [code]true[/code] if the [param piece] is in the corresponding player's starting zone.
## Otherwise return  [code]false[/code].
func is_in_start_zone(piece: Piece) -> bool:
	return _get_start_area(piece.player).get_all_pieces().has(piece)


## Returns the current [Spot] the [param piece] is on. Returns [code]null[/code] if the piece is in none.
func get_current_spot(piece: Piece) -> Spot:
	for spot in _get_start_area(piece.player).get_all_spots():
		if spot.piece == piece:
			return spot
	
	for spot in _get_track(piece.player):
		if spot.piece == piece:
			return spot
	
	for spot in _get_end_area(piece.player).get_all_spots():
		if spot.piece == piece:
			return spot
	
	return null # If piece is not placed return null

func _get_movement_path(piece: Piece, landing_spot: Spot) -> Array[Vector3]:
	# TODO: implement
	return [landing_spot.sample_position()]


func _get_start_area(player_id: int) -> PieceGroup:
	return _p_track[player_id][0]


func _get_track(player_id: int) -> Array[Spot]:
	return _p_track[player_id][1]


func _get_end_area(player_id: int) -> PieceGroup:
	return _p_track[player_id][2]
