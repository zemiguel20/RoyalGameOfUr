class_name PlayerTurn
extends Turn
## Controls the turn of a normal player, with interactive elements.


## Allows the player to roll the dice and pick a move interactively.
func start() -> void:
	_dice.start_roll_interactive(_dice_zone)
	var result = await _dice.rolled
	
	var moves: Array[GameMove] = _board.calculate_moves(result, _player, _ruleset)
	
	_dice.highlight_result(not moves.is_empty(), result != 0)
	await get_tree().create_timer(1.0).timeout
	
	if moves.is_empty():
		finished.emit(Result.NO_MOVES)
		return
	
	var selected_move: GameMove = await _select_move(moves)
	if Settings.fast_mode:
		selected_move.execute(GameMove.AnimationType.SKIPPING)
	else:
		selected_move.execute(GameMove.AnimationType.DIRECT)
	await selected_move.execution_finished
	
	if selected_move.wins:
		finished.emit(Result.WIN)
	elif selected_move.gives_extra_turn:
		finished.emit(Result.EXTRA_TURN)
	else:
		finished.emit(Result.NORMAL)


# Coroutine to select move interactively
func _select_move(moves: Array[GameMove]) -> GameMove:
	# TODO: implement interactive selection
	return moves.pick_random()
