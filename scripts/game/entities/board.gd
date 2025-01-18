class_name Board
extends Node3D
## Layout of spots composed of 2 tracks, one for each player. Manages the board state, 
## allowing queries or executing moves to update it.


const WHITE_PIECE_PREFAB: PackedScene = preload("res://scenes/game/entities/piece_white.tscn")
const BLACK_PIECE_PREFAB: PackedScene = preload("res://scenes/game/entities/piece_black.tscn")

@export var _p1_start_spots: Array[Spot] = []
@export var _p1_track: Array[Spot] = []

@export var _p2_start_spots: Array[Spot] = []
@export var _p2_track: Array[Spot] = []


## Spawns a number of pieces for each player on their starting zones.
func init(num_pieces_per_player: int) -> void:
	for i in num_pieces_per_player:
		var white_piece = WHITE_PIECE_PREFAB.instantiate()
		add_child(white_piece)
		white_piece.player = BoardGame.Player.ONE
		_p1_start_spots[i].place(white_piece)
		
		var black_piece = BLACK_PIECE_PREFAB.instantiate()
		add_child(black_piece)
		black_piece.player = BoardGame.Player.TWO
		_p2_start_spots[i].place(black_piece)


## Returns a list with all moves for a given player in the given number of steps.
func calculate_moves(steps: int, player: int, ruleset: Ruleset) -> Array[GameMove]:
	var moves: Array[GameMove] = []
	
	if steps <= 0:
		return moves
	
	var track = get_player_track(player)
	
	var occupied_starting_spots = get_player_occupied_start_spots(player)
	var has_pieces_in_start = not occupied_starting_spots.is_empty()
	var destination_spot = track[steps - 1]
	var can_move = _check_move_validity(destination_spot, player, ruleset)
	if has_pieces_in_start and can_move:
		for starting_spot in occupied_starting_spots:
			var move = GameMove.new(starting_spot, destination_spot, player, self, ruleset)
			moves.append(move)
	
	var occupied_track_spots = get_player_occupied_track_spots(player)
	for starting_spot in occupied_track_spots:
		var index = track.find(starting_spot)
		var is_last_spot = index == (track.size() - 1)
		if not is_last_spot:
			var is_move_within_bounds = (index + steps) < track.size()
			if is_move_within_bounds:
				destination_spot = track[index + steps]
				can_move = _check_move_validity(destination_spot, player, ruleset)
				if can_move:
					var move = GameMove.new(starting_spot, destination_spot, player, self, ruleset)
					moves.append(move)
		
			if ruleset.can_move_backwards:
				is_move_within_bounds = (index - steps) >= 0
				if is_move_within_bounds:
					destination_spot = track[index - steps]
					can_move = _check_move_validity(destination_spot, player, ruleset)
					if can_move:
						var move = GameMove.new(starting_spot, destination_spot, player, self, ruleset)
						moves.append(move)
	
	return moves


func get_player_start_spots(player: int) -> Array[Spot]:
	if player == BoardGame.Player.ONE:
		return _p1_start_spots.duplicate()
	else:
		return _p2_start_spots.duplicate()


func get_player_track(player : int) -> Array[Spot]:
	if player == BoardGame.Player.ONE:
		return _p1_track.duplicate()
	else:
		return _p2_track.duplicate()


func get_player_occupied_start_spots(player: int) -> Array[Spot]:
	var filter = func(spot: Spot): return spot.is_occupied_by_player(player)
	var occupied_spots = get_player_start_spots(player).filter(filter)
	return occupied_spots


func get_player_free_start_spots(player: int) -> Array[Spot]:
	var filter = func(spot: Spot): return spot.is_free()
	var free_spots = get_player_start_spots(player).filter(filter)
	return free_spots


func get_player_occupied_track_spots(player: int) -> Array[Spot]:
	var filter = func(spot: Spot): return spot.is_occupied_by_player(player)
	var occupied_spots = get_player_track(player).filter(filter)
	return occupied_spots


func get_player_free_track_spots(player: int) -> Array[Spot]:
	var filter = func(spot: Spot): return spot.is_free()
	var free_spots = get_player_track(player).filter(filter)
	return free_spots


func is_spot_safe(spot: Spot, ruleset: Ruleset) -> bool:
	var is_start_spot = _p1_start_spots.has(spot) or _p2_start_spots.has(spot)
	var is_exclusive = (_p1_track.has(spot) and not _p2_track.has(spot)) \
						or (not _p1_track.has(spot) and _p2_track.has(spot))
	var is_safe_rosette = spot.is_rosette and ruleset.rosettes_are_safe
	
	return is_start_spot or is_exclusive or is_safe_rosette


## Returns the section of the path between 2 given indexes (exclusive).
## If [param from_index] is higher than [param to_index], the returned path is backwards.
func get_path_between(from_index: int, to_index: int, player: int) -> Array[Spot]:
	var path: Array[Spot] = []
	if from_index == to_index:
		return path
	
	var track = get_player_track(player)
	
	var step = 1 if from_index <= to_index else -1
	# Add step to 'begin' to become exlusive instead of inclusive
	path = track.slice(from_index + step, to_index, step)
	
	return path


func _check_move_validity(dest_spot: Spot, player: int, ruleset: Ruleset) -> bool:
	var is_end_spot = get_player_track(player).back() == dest_spot
	
	var is_dest_safe = dest_spot.is_rosette and ruleset.rosettes_are_safe
	var is_dest_occupied_by_opponent = not dest_spot.is_free() and \
										not dest_spot.is_occupied_by_player(player)
	var is_knockout_situation = is_dest_occupied_by_opponent and not is_dest_safe
	
	var is_stacking_situation = dest_spot.is_occupied_by_player(player) and dest_spot.is_rosette \
								and ruleset.rosettes_allow_stacking
	
	var is_valid = dest_spot.is_free() or is_end_spot \
				or is_knockout_situation or is_stacking_situation
	
	return is_valid
