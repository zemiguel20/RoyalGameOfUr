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

# Pack @export data per player into dictionary to reduce "if" statements
var _p_data: Dictionary = {}


func _ready() -> void:
	# Pack player data
	_p_data[General.Player.ONE] = [_p1_piece, _p1_start_spots, _p1_track]
	_p_data[General.Player.TWO] = [_p2_piece, _p2_start_spots, _p2_track]
	
	_check_player_data()
	_clean()
	_spawn_pieces()


func get_free_start_spots(player: General.Player) -> Array[Spot]:
	var start_spots = get_start_spots(player)
	var free_spots = start_spots.filter(func(spot: Spot): return spot.is_free())
	return free_spots


func get_start_spots(player: General.Player) -> Array[Spot]:
	return (_p_data[player][1] as Array[Spot]).duplicate()


func get_track(player: General.Player) -> Array[Spot]:
	return (_p_data[player][2] as Array[Spot]).duplicate()


#region SETUP

func _check_player_data():
	assert(_p1_piece != null, "No piece prefab was assigned to Player 1")
	assert(_p2_piece != null, "No piece prefab was assigned to Player 2")
	assert(_p1_start_spots.size() <= Settings.num_pieces, \
		"Player 1 does not have enough starting spots for the specified number of pieces")
	assert(_p2_start_spots.size() <= Settings.num_pieces, \
		"Player 2 does not have enough starting spots for the specified number of pieces")


# Clean spots and despawn pieces
func _clean():
	for player in _p_data:
		var all_spots: Array[Spot] = []
		all_spots.append_array(get_start_spots(player))
		all_spots.append_array(get_track(player))
		for spot in all_spots:
			var pieces = spot.remove_pieces()
			for piece in pieces:
				piece.queue_free()


func _spawn_pieces():
	for player in _p_data:
		for i in Settings.num_pieces:
			var piece = _p_data[player][0].instantiate()
			add_child(piece)
			var free_spot = get_free_start_spots(player).pick_random() as Spot
			free_spot.place_piece(piece, Piece.MoveAnim.NONE)

#endregion

#region OLD

### Moves [param piece] to [param landing_spot]. Moves opponent piece to starting area if it gets knocked out.
#func move(piece: Piece, landing_spot: Spot) -> void:
	#var movement_path = _get_movement_path(piece, landing_spot)
	#await piece.move(movement_path)
	#
	#var opponent_id = General.get_other_player_id(piece.player)
	#if is_occupied_by_player(landing_spot, opponent_id):
		## Move opponent to start
		#var start_spot = _get_start_area(opponent_id).get_available_spot()
		#await move(landing_spot.piece, start_spot)
	#
	## Update spot info
	#get_current_spot(piece).piece = null
	#landing_spot.piece = piece
#
#
### Returns the list of all pieces of the given [param player].
#func get_pieces(player: int) -> Array[Piece]:
	#var pieces: Array[Piece] = []
	#pieces.append_array(_p_track[player][4])
	#return pieces
	#
	#
### Returns the current [Spot] the [param piece] is on. Returns [code]null[/code] if the piece is in none.
#func get_current_spot(piece: Piece) -> Spot:
	#for spot in _get_start_area(piece.player).get_all_spots():
		#if spot.piece == piece:
			#return spot
	#
	#for spot in _get_track(piece.player):
		#if spot.piece == piece:
			#return spot
	#
	#for spot in _get_end_area(piece.player).get_all_spots():
		#if spot.piece == piece:
			#return spot
	#
	#return null # If piece is not placed return null
	#
#
### Returns the spot the [param piece] will land on with the given [param roll].
### Returns [code]null[/code] if landing outside board bounds, that is, past the last spot of the track.
#func get_landing_spot(piece: Piece, roll: int) -> Spot:
	#var start_area = _get_start_area(piece.player)
	#var end_area = _get_end_area(piece.player)
	#
	## NOTE Get track with added start and end spot for simplicity since we will work with indexes
	#
	#var track  = _get_track(piece.player).duplicate()
	#var current_spot = get_current_spot(piece)
	#
	## If the current spot is either a start spot or an end spot, insert it in the track
	## Otherwise insert just an available spot
	#if start_area.get_all_spots().has(current_spot):
		#track.insert(0, current_spot)
	#else:
		#var empty_spot = start_area.get_available_spot()
		#track.insert(0, empty_spot)
	#if end_area.get_all_spots().has(current_spot):
		#track.append(current_spot)
	#else:
		#var empty_spot = end_area.get_available_spot()
		#track.append(empty_spot)
	#
	## Sample landing_spot from track using current index + roll
	#var current_index = track.find(current_spot)
	#var target_index = current_index + roll
	#if target_index < track.size():
		#return track[target_index]
	#else:
		#return null # Out of bounds
#
#
### Returns [code]true[/code] if the [param spot] is occupied by a piece of the given [param player].
### Otherwise return  [code]false[/code].
#func is_occupied_by_player(spot: Spot, player: int) -> bool:
	#return spot.piece != null and spot.piece.player == player
#
#
### Returns [code]true[/code] if the [param player] has all of its pieces in the end area.
### Otherwise return  [code]false[/code].
#func is_winner(player: int) -> bool:
	#var finished_pieces = (_p_track[player][2] as PieceGroup).get_all_pieces()
	#var player_pieces = get_pieces(player)
	#return finished_pieces.size() == player_pieces.size()
#
#
### Returns [code]true[/code] if the [param piece] is in the corresponding player's starting zone.
### Otherwise return  [code]false[/code].
#func is_in_start_zone(piece: Piece) -> bool:
	#return _get_start_area(piece.player).get_all_pieces().has(piece)
	#
	#
### Returns [code]true[/code] if the [param spot] is a spot in any of the end zones.
### Otherwise return  [code]false[/code].
#func is_in_end_zone(spot: Spot) -> bool:
	#return (_p1_end_area.get_all_spots().has(spot) or
		#_p2_end_area.get_all_spots().has(spot))
	#
	#
#func is_player_exclusive(spot: Spot) -> bool:
	#return (_p1_track.has(spot) and not _p2_track.has(spot) or
		#not _p1_track.has(spot) and _p2_track.has(spot))
		#
		#
### Used by AI, will refactor later.
#func is_capturable(spot: Spot, opponent_id: General.PlayerID) -> bool:
	#return is_occupied_by_player(spot, opponent_id) and not spot.is_safe
	#
	#
#func get_spot(index: int, opponent: General.PlayerID):
	#return _get_track(opponent)[index]
	#
	#
#func get_spot_index(spot: Spot, player: General.PlayerID) -> int:
	#return _get_track(player).find(spot)
	#
	#
#func get_num_pieces_past_spot(spot: Spot, player: General.PlayerID) -> int:
	## Num of pieces still at the end
	#var spot_index = get_spot_index(spot, player)
	#
	#var num_passed_pieces = 0
	#for piece: Piece in get_pieces(player):
		#if (is_in_end_zone(get_current_spot(piece)) or
			#get_spot_index(get_current_spot(piece), player) > spot_index):
			#num_passed_pieces += 1
	#
	#return num_passed_pieces
	#
	#
#func get_track_size(player: General.PlayerID):
	#return _get_track(player).size()
	#
#
#func _get_movement_path(piece: Piece, landing_spot: Spot) -> Array[Vector3]:
	## if going back to start zone, go directly
	#if _get_start_area(piece.player).get_all_spots().has(landing_spot):
		#return [landing_spot.sample_position()]
	#
	## NOTE Get sequence of spots using slice. Slice start and end indexed are [inclusive, exclusive[ respectively.
	#
	## Get track with appended end spot for simplicity since were working with indexes and slice.
	## If landing spot is end zone, add it, else add a sampled empty spot
	#var temp_track = _get_track(piece.player).duplicate()
	#if _get_end_area(piece.player).get_all_spots().has(landing_spot):
		#temp_track.append(landing_spot)
	#else:
		#var empty_spot = _get_end_area(piece.player).get_available_spot()
		#temp_track.append(empty_spot)
	#
	## For the start index, we want one index after the current spot, so use find index of current spot on track and add 1.
	## If find returns -1, means piece is in start zone, so start index will be 0 (the first tile).
	#var current_spot = get_current_spot(piece)
	#var start_index = temp_track.find(current_spot) + 1
	#
	## Find index of landing spot. Add 1 because slice is exclusive
	#var end_index = temp_track.find(landing_spot) + 1
	#
	## Slice the track
	#var spot_path = temp_track.slice(start_index, end_index)
	#
	## Transform into array of positions
	#var positions: Array[Vector3] =[]
	#for spot: Spot in spot_path:
		#positions.append(spot.sample_position())
	#
	#return positions
#
#
#func _get_start_area(player_id: int) -> PieceGroup:
	#return _p_track[player_id][0]
#
#
#func _get_track(player_id: int) -> Array[Spot]:
	#return _p_track[player_id][1]
#
#
#func _get_end_area(player_id: int) -> PieceGroup:
	#return _p_track[player_id][2]

#endregion
