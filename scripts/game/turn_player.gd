class_name PlayerTurn
extends Turn
## Controls the turn of a normal player interactively.


## Allows the player to roll the dice and pick a move interactively.
func start() -> void:
	_dice.start_roll_interactive(_dice_zone)
	var result = await _dice.rolled
	
	var moves: Array[GameMove] = _board.calculate_moves(result)
	
	_dice.highlight_result(not moves.is_empty(), result != 0)
	await _scene_tree.create_timer(1.0).timeout
	
	if moves.is_empty():
		finished.emit(Result.NO_MOVES)
		return
	
	# TODO: implement move picking
	
	# PLACE HOLDER
	var rand_result = Result[Result.keys().pick_random()]
	finished.emit(rand_result)
