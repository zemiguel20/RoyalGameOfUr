class_name AIPlayerAdvanced
extends AIPlayerBase

## Keep in mind that the default values are just an estimate of what a difficult AI would have.
## Changing these values can greatly impact the behaviour of the AI

@export_category("Base Scores")
@export_range(0, 1) var capture_base_score: float = 0.9
@export_range(0, 1) var grants_roll_base_score: float  = 0.7
@export_range(0, 1) var end_move_base_score: float = 0.6
@export_range(0, 1) var regular_base_score: float = 0.5

@export_category("Score modifiers")
@export_range(0, 1) var safety_score_weight: float = 0.4
## Base danger value for tiles that are not 100% safe, so spots that are on the path of both players.
@export_range(0, 1) var base_spot_danger: float = 0.1
## Pieces that are further across the board get more priority
@export_range(0, 1) var piece_progress_score_weight: float = 0.2
## Float that decides priority of occupying a central rosette.
## A central rosette is defined as a rosette that is on both the p1 and p2 track. 
@export_range(0, 1) var central_rosette_score_weight: float = 0.2
## I made the assumption that occupying the central rosettes is better, the more opponent pieces are still at the start.
## Turning this bool off, will only check deduct points when ALL of the opponents pieces are past the central rosette.
@export var decrease_per_passed_opponent_piece: bool = true


func _evaluate_moves(moves : Array[Move]) -> Move:
	var best_move = null
	var best_move_score = -1
	
	for move in moves:
		# Make extra sure that ai wont move back when it has a winning move.
		if move.is_winning_move():
			return move
		
		var score = _evaluate_move(move)
		if score > best_move_score:
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
	## If move is capture
	if move.is_capture():
		return capture_base_score
	## If move gives extra roll		
	elif move.gives_extra_roll():
		return grants_roll_base_score
	## If move is end move.		
	elif move.moves_to_end_zone():
		return end_move_base_score
	else:
		return regular_base_score


func _calculate_safety_modifier(move: Move):
	var safety_difference = move.calculate_safety_difference(base_spot_danger)
	return safety_score_weight * safety_difference
	
	
func _calculate_progress_modifier(move: Move):
	var progression = move.get_progression_score()	# Value between 0 and 1
	return piece_progress_score_weight * progression 
	
	
func _calculate_central_rosette_modifier(move: Move):
	var current_spot = move.old_spot as Spot
	var landing_spot = move.new_spot as Spot
	var is_current_spot_central_rosette = move._is_central_rosette(current_spot)
	var is_landing_spot_central_rosette = move._is_central_rosette(landing_spot)
	
	if (not is_current_spot_central_rosette and not is_landing_spot_central_rosette):
		return 0
		
	
	var num_of_total_pieces = Settings.num_pieces
	
	var score = 1
	if (num_of_passed_pieces != 0 and decrease_per_passed_opponent_piece):	
		var passed_pieces_rate: float = (num_of_passed_pieces as float / num_of_total_pieces)	# Value between 0 and 1
		score = 1 - passed_pieces_rate	# Value between 0 and 1
	
	var final_score = 0
	if is_current_spot_central_rosette:
		final_score -= score
	if is_landing_spot_central_rosette:
		final_score += score
	
	return central_rosette_score_weight * final_score
