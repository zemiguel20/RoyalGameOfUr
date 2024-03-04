class_name AIPlayerAdvanced
extends AIPlayerBase

@export_category("Base Scores")
@export_range(0, 1) var capture_base_score: float
@export_range(0, 1) var grants_roll_base_score: float
@export_range(0, 1) var end_move_base_score: float
@export_range(0, 1) var regular_base_score: float

@export_category("Score modifiers")
@export_range(0, 1) var safety_score_weight: float
## A central rosette is defined as a rosette that is on both the p1 and p2 track.
@export_range(0, 1) var piece_progress_score_weight: float
## Float that decids
## A central rosette is defined as a rosette that is on both the p1 and p2 track. 
@export_range(0, 1) var central_rosette_score_weight: float


# Note: This function will be the same for many of the AI, the only exception is the random ai.
func _evaluate_moves(moves : Array[Move]) -> Piece:
	var best_move = null
	var best_move_score = 0		# Lowest score by default

	
	for move in moves:
		# move = move2
		var score = _evaluate_move(move)
		if (score > best_move_score):
			best_move_score = score
			best_move = move
			
	return best_move.piece


# Very temporary, or perhaps for a very medium AI
func _evaluate_move(move: Move) -> float:
	# Exception: If move is move to end_area, we should skip most of the modifiers.
	
	var score = _calculate_base_score(move)
	score += _calculate_safety_modifier(move)
	score += _calculate_progress_modifier(move)
	score += _calculate_central_rosette_modifier(move)
	return score
	
		
func _calculate_base_score(move: Move):
	var landing_spot = move.spot
	
	if _board.is_capturable(landing_spot, General.PlayerID.TWO):
		return capture_base_score
	elif (landing_spot.is_rosette):
		# TODO: When adding more rulesets, the is_rosette should be seperated in is_safe and grants_extra_roll,
		# since in some rulesets rosettes are not safe.
		return grants_roll_base_score
	elif (_board.is_in_end_zone(landing_spot)):
		return end_move_base_score
	else:
		return regular_base_score


func _calculate_safety_modifier(move: Move):
	if (move.grants_extra_roll):
		return 0
		
	var old_spot_danger = _calculate_spot_danger(move.old_spot)
	var new_spot_danger = _calculate_spot_danger(move.new_spot)
	var spot_safety_difference = old_spot_danger - new_spot_danger 	# Value between -1 and 1
		
	return spot_safety_difference * safety_score_weight
	
	
func _calculate_progress_modifier(move: Move):
	var current_tile_index = _board.get_spot_index(move.old_spot, _player_id)
	var track_count = _board.get_track_count()
	var progression = current_tile_index/track_count	# Value between 0 and 1
	
	return progression * piece_progress_score_weight
	
	
func _calculate_central_rosette_modifier(move: Move):
	var landing_spot = move.spot
	var is_central_rosette = landing_spot.is_rosette and not _board.is_player_exclusive(landing_spot)
	
	if (not is_central_rosette):
		return 0
		
	# FIXME TODO
	var opponent_id = General.get_other_player_id(_player_id)
	var num_of_passed_pieces = _board.get_num_pieces_past_spot(move.new_spot, opponent_id)
	# TODO: Replace with num_of_pieces in gamemode/gamerules.
	var num_of_total_pieces = 7
	
	# I made the assumption that occupying the central rosettes is better, the more opponent pieces are still at the start.
	var score = 1
	if (num_of_passed_pieces != 0):	
		var passed_pieces_rate = (num_of_passed_pieces / num_of_total_pieces)	# Value between 0 and 1
		score = 1 - passed_pieces_rate											# Value between 0 and 1
	return central_rosette_score_weight * score
	
	
func _calculate_spot_danger(spot: Spot) -> int:
	# Give score of 0 when landing_spot is 100% safe. 
	if (spot.is_rosette || _board.is_player_exclusive(spot)):
		return 0
	
	var index = _board.get_spot_index(spot, _player_id)
	var total_capture_chance
	
	# Check the 4 tiles before this spot for opponent pieces
	for _i in range(1, 5):
		var temp_spot = _board.get_spot(index - _i, _player_id)
		var contains_opponent = _board.is_occupied_by_player(temp_spot, _player_id) 
		if (contains_opponent):
			var capture_chance = 0.5	# TODO: Replace with actual chances
			total_capture_chance += capture_chance
	
	return total_capture_chance
	
