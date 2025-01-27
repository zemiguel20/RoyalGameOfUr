class_name AIGameMoveSelector
extends GameMoveSelector
## Evaluates moves based on different weights, etc., giving them a score.
## Picks the best move.


signal extra_thinking_needed

const BASE_THINK_DURATION: float = 0.3
const MIN_EXTRA_THINK_DURATION: float = 0.5
const MAX_EXTRA_THINK_DURATION: float = 1.5
const MOVE_HIGHLIGHT_DURATION: float = 1.0

## Chance for the opponent to pick the best move available
const BEST_MOVE_WEIGHT: int = 9
## Chance for the opponent to pick the second best move available
const SECOND_BEST_MOVE_WEIGHT: int = 1
## Chance for the opponent to pick a random suboptimal move
const OTHER_RANDOM_MOVE_WEIGHT: int = 0

const KO_SCORE: float = 0.53
const GIVE_EXTRA_TURN_SCORE: float = 0.25
const END_OF_TRACK_SCORE: float = 0.10
const PROGRESSION_SCORE: float = 0.12
const SAFETY_SCORE: float = 0.2

var _board: Board


func init(board: Board) -> void:
	_board = board


func start_selection(moves: Array[GameMove]) -> void:
	await get_tree().create_timer(BASE_THINK_DURATION).timeout
	
	if _is_shared_path_crowded():
		extra_thinking_needed.emit()
		var extra_think_duration = randf_range(MIN_EXTRA_THINK_DURATION, MAX_EXTRA_THINK_DURATION)
		await get_tree().create_timer(extra_think_duration).timeout
	
	var selected_move = _determine_next_move(moves)
	
	if not Settings.fast_mode:
		await _highlight_move_duration(selected_move, MOVE_HIGHLIGHT_DURATION)
	
	selected_move.execute(GameMove.AnimationType.SKIPPING)
	await selected_move.execution_finished
	move_selected.emit(selected_move)


func _is_shared_path_crowded() -> int:
	var shared_spots = _board.get_shared_track_spots()
	var occupied_shared_spots = shared_spots.filter(func(spot: Spot): return not spot.is_free())
	return occupied_shared_spots.size() >= 3


func _determine_next_move(moves: Array[GameMove]) -> GameMove:
	if moves.size() == 1:
		return moves[0]
	
	moves.sort_custom(func(a, b): return _evaluate_move(a) > _evaluate_move(b))
	
	# NOTE: Uses weighted random for choosing move
	var total_weight = BEST_MOVE_WEIGHT + SECOND_BEST_MOVE_WEIGHT + OTHER_RANDOM_MOVE_WEIGHT
	var rand = randi_range(0, total_weight)
	if rand < BEST_MOVE_WEIGHT:
		return moves[0]
	elif moves.size() == 2 or rand < BEST_MOVE_WEIGHT + SECOND_BEST_MOVE_WEIGHT:
		return moves[1]
	else:
		moves.pop_front() # Remove best move
		moves.pop_front() # Remove second best move
		return moves.pick_random()


# TODO: improve score evaluation if move is backwards. Favours going back to first safe spots.
func _evaluate_move(move: GameMove) -> float:
	var score: float = 0.0
	
	if move.knocks_opponent_out:
		score += KO_SCORE
	
	if move.gives_extra_turn:
		score += GIVE_EXTRA_TURN_SCORE
	
	score += _calculate_track_progress_score(move)
	score += _calculate_safety_difference_score(move)
	
	return score


func _calculate_track_progress_score(move: GameMove) -> float:
	var track = _board.get_player_track(move.player)
	var progression = float(move.to_track_index) / (track.size() - 1)
	var score = progression * PROGRESSION_SCORE
	
	if move.to_is_end_of_track:
		score += END_OF_TRACK_SCORE
	
	return score


func _calculate_safety_difference_score(move: GameMove) -> float:
	# NOTE: the higher the difference, the better impact the move
	# has on the pieces protection from KO.
	var score = (move.from_ko_prob - move.to_ko_prob) * SAFETY_SCORE
	
	# Shared safe spots are important, so difference is amplified if moving out or into one.
	var shared_safe_modifier = SAFETY_SCORE * 0.5
	if move.from_is_safe and move.from_is_shared:
		score -= shared_safe_modifier
	if move.to_is_safe and move.to_is_shared:
		score += shared_safe_modifier
	
	return score


func _highlight_move_duration(move: GameMove, duration: float) -> void:
	_highlight_move(move)
	await get_tree().create_timer(duration).timeout
	_clear_move_highlight(move)
