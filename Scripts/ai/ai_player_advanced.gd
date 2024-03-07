class_name AIPlayerAdvanced
extends AIPlayerBase

## Keep in mind that the default values are just an estimate of what a difficult AI would have.

@export_category("Base Scores")
@export_range(0, 1) var capture_base_score: float = 0.9
@export_range(0, 1) var grants_roll_base_score: float  = 0.7
@export_range(0, 1) var end_move_base_score: float = 0.6
@export_range(0, 1) var regular_base_score: float = 0.5

@export_category("Score modifiers")
@export_range(0, 1) var safety_score_weight: float = 0.4
## A central rosette is defined as a rosette that is on both the p1 and p2 track.
@export_range(0, 1) var piece_progress_score_weight: float = 0.2
## Float that decides how much the AI cares about occupying a central rosette.
## A central rosette is defined as a rosette that is on both the p1 and p2 track. 
@export_range(0, 1) var central_rosette_score_weight: float = 0.2
## Base danger value for tiles that are not 100% safe, so spots that are on the path of both players.
@export_range(0, 1) var base_spot_danger: float = 0.1


# NOTE: This function will be the same for many of the AI, the only exception is the random ai.
func _evaluate_moves(moves : Array[Move]) -> Piece:
	var best_move = null
	var best_move_score = -1
	
	for move in moves:
		# move = move2
		var score = _evaluate_move(move)
		if (score > best_move_score):
			best_move_score = score
			best_move = move
			
	return best_move.piece


func _evaluate_move(move: Move) -> float:
	var score = _calculate_base_score(move)
	score += _calculate_safety_modifier(move)
	score += _calculate_progress_modifier(move)
	score += _calculate_central_rosette_modifier(move)
	return score
	
		
func _calculate_base_score(move: Move):
	var landing_spot := move.new_spot
	
	if _board.is_capturable(landing_spot, General.get_other_player_id(_player_id)):
		return capture_base_score
	elif (landing_spot.give_extra_roll):
		return grants_roll_base_score
	elif (_board.is_in_end_zone(landing_spot)):
		return end_move_base_score
	else:
		return regular_base_score


func _calculate_safety_modifier(move: Move):
	var old_spot_danger = _calculate_spot_danger(move.old_spot)
	var new_spot_danger = _calculate_spot_danger(move.new_spot)
	var spot_safety_difference = old_spot_danger - new_spot_danger 	# Value between -1 and 1
		
	return spot_safety_difference * safety_score_weight
	
	
func _calculate_progress_modifier(move: Move):
	var current_tile_index = _board.get_spot_index(move.old_spot, _player_id)
	var track_size = _board.get_track_size(_player_id)
	var progression: float = (current_tile_index + 1.0)/track_size		# Value between 0 and 1
	
	return piece_progress_score_weight * progression 
	
	
func _calculate_central_rosette_modifier(move: Move):
	var current_spot = move.old_spot as Spot
	var landing_spot = move.new_spot as Spot
	var is_current_spot_central_rosette = _is_central_rosette(current_spot)
	var is_landing_spot_central_rosette = _is_central_rosette(landing_spot)
	
	if (not is_current_spot_central_rosette and not is_landing_spot_central_rosette):
		return 0
		
	var opponent_id = General.get_other_player_id(_player_id)
	var num_of_passed_pieces = _board.get_num_pieces_past_spot(move.new_spot, opponent_id)
	var num_of_total_pieces = _gamemode.num_pieces_per_player
	
	# I made the assumption that occupying the central rosettes is better, the more opponent pieces are still at the start.
	var score = 1
	if (num_of_passed_pieces != 0):	
		var passed_pieces_rate: float = (num_of_passed_pieces as float / num_of_total_pieces)	# Value between 0 and 1
		score = 1 - passed_pieces_rate													# Value between 0 and 1
	
	var final_score = 0
	if (is_current_spot_central_rosette):
		final_score -= score
	if (is_landing_spot_central_rosette):
		final_score += score
	
	return central_rosette_score_weight * final_score
	
	
func _calculate_spot_danger(spot: Spot) -> float:
	# Give score of 0 when landing_spot is 100% safe. 
	if (spot.is_safe or spot.give_extra_roll or _board.is_player_exclusive(spot) ):
		return 0
	
	# When a spot is not player exclusive, there is always a bit of danger.
	var total_capture_chance = 0.0
	var index = _board.get_spot_index(spot, _player_id)
	var opponent_id = General.get_other_player_id(_player_id)
	
	# Check the 4 tiles before this spot for opponent pieces
	for _i in range(1, 5):
		var temp_spot = _board.get_spot(index - _i, opponent_id)
		var contains_opponent = _board.is_occupied_by_player(temp_spot, opponent_id) 
		if (contains_opponent):
			var capture_chance = DiceProbabilities.get_probability_of_value(_i, DiceProbabilities.DiceType.Binary, 4)
			total_capture_chance += capture_chance
	
	return base_spot_danger + total_capture_chance
	
	
# Could also move this to board maybe?
func _is_central_rosette(spot: Spot) -> bool:
	return spot.is_safe and not _board.is_player_exclusive(spot)
