class_name AIMovePicker
extends MovePicker
## Evaluates moves based on different weights, etc., giving them a score.
## Picks the best move.
##
## Keep in mind that the default values are just an estimate of what a difficult AI would have.
## Changing these values can greatly impact the behaviour of the AI

signal _on_suboptimal_move
signal _on_player_piece_captured

@export_group("Move picking chances")
## Chance for the opponent to pick the best move available to them, using a weight system
@export var _best_move_weight: int = 10
## Chance for the opponent to pick the second best move available to them, using a weight system
@export var _second_move_weight: int = 0
## Chance for the opponent to pick a random suboptimal move, using a weight system
@export var _random_move_weight: int = 0

@export_group("Base Scores")
@export_range(0, 1) var capture_base_score: float = 0.9
@export_range(0, 1) var grants_roll_base_score: float  = 0.7
@export_range(0, 1) var end_move_base_score: float = 0.6
@export_range(0, 1) var regular_base_score: float = 0.5

@export_group("Score modifiers")
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


func start(moves: Array[Move]) -> void:
	# Simulate thinking
	await get_tree().create_timer(0.2).timeout
	var best_move: Move = _determine_next_move(moves)
			
	# Execute move
	await best_move.execute(Piece.MoveAnim.ARC)
	move_executed.emit(best_move)
	
	
func _determine_next_move(moves : Array[Move]) -> Move:
	if (moves.size() == 1):
		return moves[0]

	var ordered_moves = moves.duplicate()
	ordered_moves.sort_custom(_sort_best_moves)
	
	var result: Move
	var rand = randi_range(0, _best_move_weight + _second_move_weight + _random_move_weight)
	if rand < _best_move_weight:
		result = ordered_moves[0]
	elif rand < _best_move_weight + _second_move_weight or moves.size() == 2:
		_on_suboptimal_move.emit()
		result = ordered_moves[1]
	else:
		_on_suboptimal_move.emit()
		result = ordered_moves[randi_range(2, ordered_moves.size()-1)]
		
	if result.knocks_opo:
		_on_player_piece_captured.emit()
		
	return result


func _sort_best_moves(a, b):
	return _evaluate_move(a) > _evaluate_move(b)


func _evaluate_move(move: Move) -> float:
	var score = _calculate_base_score(move)
	score += _calculate_safety_modifier(move)
	score += _calculate_progress_modifier(move)
	score += _calculate_central_rosette_modifier(move)
	return score
	
	
func _calculate_base_score(move: Move):
	if move.knocks_opo:
		return capture_base_score
	elif move.gives_extra_turn:
		return grants_roll_base_score
	elif move.moves_to_end:
		return end_move_base_score
	else:
		return regular_base_score


#region ScoreModifiers
func _calculate_safety_modifier(move: Move):
	var safety_difference = move.calculate_safety_difference(base_spot_danger)
	return safety_score_weight * safety_difference
	
	
func _calculate_progress_modifier(move: Move):
	var progression = move.from_track_pos
	return piece_progress_score_weight * progression 
	
	
func _calculate_central_rosette_modifier(move: Move):
	var is_current_spot_central_rosette = move.is_from_central_safe
	var is_landing_spot_central_rosette = move.is_to_central_safe
	
	if (not is_current_spot_central_rosette and not is_landing_spot_central_rosette):
		return 0
	
	var score = 1
	# Extra rule: the more pieces are already past the from tile, the less efficient this strategy is.
	if decrease_per_passed_opponent_piece:
		var num_of_passed_pieces = move.num_pieces_past_current_spot()
		var num_of_total_pieces = Settings.num_pieces
		var passed_pieces_rate: float = (num_of_passed_pieces as float / num_of_total_pieces)	# Value between 0 and 1
		score = 1 - passed_pieces_rate	# Value between 0 and 1
	
	var final_score = 0
	if is_landing_spot_central_rosette:
		final_score += score
	elif is_current_spot_central_rosette:
		final_score -= score
	
	return central_rosette_score_weight * final_score
#endregion
