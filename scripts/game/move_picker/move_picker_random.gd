class_name RandomMovePicker
extends MovePicker
## Picks a random move. Mostly useful as a mock picker for testing scenarios.


## Immediately picks a random move from [param moves].
func start(moves : Array[Move]) -> void:
	var move = moves.pick_random() as Move
	move.execute()
	await move.execution_finished
	move_executed.emit(move)
