class_name Board
extends Node
## Manages the state of the board. It stores in which spot the pieces of each player are.
## It allows queries to the state of the board, and also moves the pieces.

@export_subgroup("Player 1 Data")
@export var _p1_piece: PackedScene
@export var _p1_start_spots: Array[Spot]
@export var _p1_track: Array[Spot]
@export_subgroup("Player 2 Data")
@export var _p2_piece: PackedScene
@export var _p2_start_spots: Array[Spot]
@export var _p2_track: Array[Spot]

var _p1_data : PlayerData
var _p2_data : PlayerData


func _ready() -> void:
	# Check player data
	assert(_p1_piece, "No piece prefab was assigned to Player 1")
	assert(_p2_piece, "No piece prefab was assigned to Player 2")
	assert(_p1_start_spots.size() >= Settings.num_pieces, \
		"Player 1 does not have enough starting spots for the specified number of pieces")
	assert(_p2_start_spots.size() >= Settings.num_pieces, \
		"Player 2 does not have enough starting spots for the specified number of pieces")
	
	# Init player data
	_p1_data = PlayerData.new(_p1_start_spots, _p1_track, _p1_piece)
	_p2_data = PlayerData.new(_p2_start_spots, _p2_track, _p2_piece)
	
	# Position pieces
	for piece : Piece in _p1_data.piece_spot_dict:
		add_child(piece)
		var spot = _p1_data.piece_spot_dict[piece] as Spot
		piece.move(spot.global_position)
	
	for piece : Piece in _p2_data.piece_spot_dict:
		add_child(piece)
		var spot = _p2_data.piece_spot_dict[piece] as Spot
		piece.move(spot.global_position)


## Returns a copy of the array with all start spots from [param player].
func get_start_spots(player : int) -> Array[Spot]:
	var data = _get_player_data(player)
	return data.start_spots.duplicate()


## Returns a new array with the start spots from [param player] without any pieces.
func get_free_start_spots(player : int) -> Array[Spot]:
	var free_spots = get_start_spots(player).filter(is_spot_free)
	return free_spots


## Returns a new array with the start spots from [param player] with a piece.
func get_occupied_start_spots(player : int) -> Array[Spot]:
	var occupied_spots = get_start_spots(player).filter(is_spot_occupied)
	return occupied_spots


## Returns a copy of the array with the spot sequence for the given [param player].
func get_track(player : int) -> Array[Spot]:
	var data = _get_player_data(player)
	return data.track.duplicate()


## Returns a new array with all spots in the track of the given [param player]
## where a piece owned by [param player] is placed.
## If [param include_last] is [param true], then it will also check the end spot.
func get_occupied_track_spots(player : int, include_last := false) -> Array[Spot]:
	var track = get_track(player)
	
	if not include_last:
		track.pop_back()
		
	var occupied_spots = track.filter(
		func(spot: Spot): return is_spot_occupied_by_player(spot, player))
		
	return occupied_spots


## Returns an array with the pieces placed in the given [param spot].
func get_spot_pieces(spot : Spot) -> Array[Piece]:
	var pieces : Array[Piece] = []
	
	# Searches both players data for pieces connected to the given spot
	var all_pieces_data = _p1_data.piece_spot_dict.duplicate()
	all_pieces_data.merge(_p2_data.piece_spot_dict)
	for piece : Piece in all_pieces_data:
		if all_pieces_data[piece] == spot:
			pieces.append(piece)
	
	return pieces


## Calculates and returns a list with all the possible moves.
func get_possible_moves(player : int, steps : int) -> Array[Move]:
	var moves: Array[Move] = []
	
	if steps <= 0:
		return moves
	
	# Get all spots where the player has pieces
	var occupied_spots: Array[Spot] = []
	occupied_spots.append_array(get_occupied_start_spots(player))
	occupied_spots.append_array(get_occupied_track_spots(player))
	
	for spot in occupied_spots:
		# Calculate landing spot (also for backwards movement if enabled)
		var landing_spots = [] as Array[Spot]
		landing_spots.append(_get_landing_spot(player, spot, steps))
		if Settings.can_move_backwards:
			landing_spots.append(_get_landing_spot(player, spot, steps, true))
		
		# If landing spot is valid, then create Move entry
		for landing_spot in landing_spots:
			if landing_spot and _can_place(player, landing_spot):
				var move: Move = Move.new(self, player, spot, landing_spot)
				moves.append(move)
		
	return moves


## Checks if the [param spot] does not have any piece.
func is_spot_free(spot : Spot) -> bool:
	# Check for each player if any of their pieces is connected to this spot
	var p1_occupies = _p1_data.piece_spot_dict.values().has(spot)
	var p2_occupies = _p2_data.piece_spot_dict.values().has(spot)
	
	return not p1_occupies and not p2_occupies


## Checks if the [param spot] has a piece.
func is_spot_occupied(spot : Spot) -> bool:
	return not is_spot_free(spot)


## Checks if the given [param player] is has any piece on the given [param spot].
func is_spot_occupied_by_player(spot : Spot, player : int) -> bool:
	var data = _get_player_data(player)
	return data.piece_spot_dict.values().has(spot)


## Returns whether the given [param spot] is exclusive to one of the player's track.
func is_spot_exclusive(spot : Spot) -> bool:
	return (_p1_data.track.has(spot) and not _p2_data.track.has(spot)) or \
	(not _p1_data.track.has(spot) and _p2_data.track.has(spot))


func _get_landing_spot(player : int, spot: Spot, steps: int, backwards := false) -> Spot:
	var track = get_track(player)
	var index = track.find(spot) # NOTE: In this case, -1 means its a starting spot
	
	if not backwards and (index + steps) < track.size():
		return track[index + steps]
	
	if backwards and (index - steps) >= 0:
		return track[index - steps]
	
	var free_start_spots = get_free_start_spots(player)
	if backwards and (index - steps) == -1 and not free_start_spots.is_empty():
		return free_start_spots.pick_random()
	
	return null


func _can_place(player : int, spot : Spot) -> bool:
	# Check if any rule is violated
	
	# Cannot stack if spot is not safe or force stack not enabled
	if is_spot_occupied_by_player(spot, player) and not spot.force_allow_stack and not spot.is_safe:
		return false
	
	# Cannot stack in safe spot if force stack or game setting not enabled
	if is_spot_occupied_by_player(spot, player) and not spot.force_allow_stack \
	and spot.is_safe and Settings.can_stack_in_safe_spot:
		return false
	
	# Cannot play in safe spot occupied by opponent
	var opponent = General.get_opponent(player)
	if is_spot_occupied_by_player(spot, opponent) and spot.is_safe:
		return false
	
	return true


func _get_player_data(player : int) -> PlayerData:
	if player == General.Player.ONE:
		return _p1_data
	else:
		return _p2_data


class PlayerData:
	var start_spots : Array[Spot] = []
	var track : Array[Spot] = []
	var piece_spot_dict : Dictionary = {} # Piece -> Spot where piece is
	
	func _init(start_spots : Array[Spot], track : Array[Spot], piece_scn : PackedScene):
		self.start_spots = start_spots
		self.track = track
		
		# Instantiate pieces and assign them to a starting spot
		for i in Settings.num_pieces:
			var piece = piece_scn.instantiate()
			var spot = start_spots[i]
			piece_spot_dict[piece] = spot
