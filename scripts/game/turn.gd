class_name TurnController
extends Node
## Controls the actions during a turn.


signal turn_finished(result: Result)

enum Result {
	NORMAL,
	EXTRA_TURN,
	WIN,
	NO_MOVES,
}

var roll_controller: RollController
var move_selector: GameMoveSelector

var _player: int
var _board: Board
var _ruleset: Ruleset


func init(player: int, p_roll_controller: RollController, p_move_selector: GameMoveSelector, \
			board: Board, ruleset: Ruleset) -> void:
	_player = player
	roll_controller = p_roll_controller
	move_selector = p_move_selector
	_board = board
	_ruleset = ruleset


func start_turn() -> void:
	roll_controller.start_roll()
	var result = await roll_controller.rolled
	
	var moves: Array[GameMove] = _board.calculate_moves(result, _player, _ruleset)
	
	roll_controller.highlight_result(not moves.is_empty())
	
	# Highlight the roll result of a short period before continuing
	await get_tree().create_timer(0.4).timeout
	
	if moves.is_empty():
		roll_controller.clear_highlight()
		turn_finished.emit(Result.NO_MOVES)
		return
	
	move_selector.start_selection(moves)
	var selected_move: GameMove = await move_selector.move_selected
	
	roll_controller.clear_highlight()
	
	if selected_move.wins:
		turn_finished.emit(Result.WIN)
	elif selected_move.gives_extra_turn:
		turn_finished.emit(Result.EXTRA_TURN)
	else:
		turn_finished.emit(Result.NORMAL)
