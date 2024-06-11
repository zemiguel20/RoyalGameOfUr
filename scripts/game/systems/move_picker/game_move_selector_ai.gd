class_name AIGameMoveSelector extends Node
## Evaluates moves based on different weights, etc., giving them a score.
## Picks the best move.
##
## Keep in mind that the default values are just an estimate of what a difficult AI would have.
## Changing these values can greatly impact the behaviour of the AI


signal move_selected(move: GameMove)

@export var highlight: GameMoveHighlight

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
## Pieces that are further across the board get more priority
@export_range(0, 1) var piece_progress_score_weight: float = 0.2
## Float that decides priority of occupying a central rosette.
## A central rosette is defined as a rosette that is on both the p1 and p2 track. 
@export_range(0, 1) var central_rosette_score_weight: float = 0.2
## I made the assumption that occupying the central rosettes is better, the more opponent pieces are still at the start.
## Turning this bool off, will only check deduct points when ALL of the opponents pieces are past the central rosette.
@export var decrease_per_passed_opponent_piece: bool = true

@export_group("Selection Behaviour")
## Minimum duration the AI will take to choose a move. 
## We simulate thinking time so that the AI feels more humane.
@export_range(0.1,3.0) var min_moving_duration: float = 0.3
## Maximum duration the AI will take to choose a move. 
## We simulate thinking time so that the AI feels more humane.
@export_range(0.1,3.0) var max_moving_duration: float = 2.0
## Duration of the highlight of the chosen move
@export_range(0.1, 5.0) var move_highlight_duration: float = 1.0


func start_selection(moves: Array[GameMove]) -> void:
	if not Settings.fast_move_enabled:
		# Simulate thinking
		var thinking_duration = fixed_moving_duration
		if fixed_moving_duration == -1:
			thinking_duration = randf_range(min_moving_duration, max_moving_duration)
		await get_tree().create_timer(thinking_duration).timeout
	var selected_move = _determine_next_move(moves)
	
	# Highlight selected move for a bit
	highlight.highlight(selected_move)
	await get_tree().create_timer(move_highlight_duration).timeout
	highlight.clear_highlight(selected_move)
	
	move_selected.emit(selected_move)


func _determine_next_move(moves: Array[GameMove]) -> GameMove:
	var valid_moves = moves.filter(func(move: GameMove): return move.valid)
	if (valid_moves.size() == 1):
		return valid_moves[0]
	
	valid_moves.sort_custom(_sort_best_moves)
	
	var rand = randi_range(0, _best_move_weight + _second_move_weight + _random_move_weight)
	if rand < _best_move_weight:
		return valid_moves[0]
	elif rand < _best_move_weight + _second_move_weight or valid_moves.size() == 2:
		return valid_moves[1]
	else:
		return valid_moves[2]


# TODO: PORT THIS TO OPPONENT LOGIC, BY CHECKING GAME STATE
#func _check_for_tutorial_signals(move: Move):
	## TODO: Only run this method when playing with default rules
	#on_play_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_EXPLANATION)
	#
	#if move.knocks_opo:
		#on_play_tutorial_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_PLAYER_GETS_CAPTURED)
		#has_emitted_tutorial_capture_signal = true
	#
	#if move.to.is_safe:
		#if move.is_to_central_safe:
			#on_play_tutorial_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_CENTRAL_ROSETTE)
		#else:
			#on_play_tutorial_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_ROSETTE)
	#
	#if move.to.force_allow_stack:
		#on_play_tutorial_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_FINISH)


func _sort_best_moves(a, b):
	return _evaluate_move(a) > _evaluate_move(b)


func _evaluate_move(move: GameMove) -> float:
	var score = _calculate_base_score(move)
	score += _calculate_safety_modifier(move)
	score += _calculate_progress_modifier(move)
	score += _calculate_central_rosette_modifier(move)
	return score


func _calculate_base_score(move: GameMove):
	if move.knocks_opo:
		return capture_base_score
	elif move.gives_extra_turn:
		return grants_roll_base_score
	elif move.moves_to_end:
		return end_move_base_score
	else:
		return regular_base_score


#region ScoreModifiers
func _calculate_safety_modifier(move: GameMove):
	return safety_score_weight * move.safety_score
	
	
func _calculate_progress_modifier(move: GameMove):
	var progression = move.from_track_pos
	return piece_progress_score_weight * progression 
	
	
func _calculate_central_rosette_modifier(move: GameMove):
	var is_current_spot_central_rosette = move.is_from_central and move.from.safe
	var is_landing_spot_central_rosette = move.is_to_central and move.to.safe
	
	if (not is_current_spot_central_rosette and not is_landing_spot_central_rosette):
		return 0
	
	var score = 1
	# Extra rule: the more pieces are already past the from tile, the less efficient this strategy is.
	if decrease_per_passed_opponent_piece:
		var num_of_passed_pieces = move.num_opo_pieces_ahead
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
