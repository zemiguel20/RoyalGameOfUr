class_name RandomMovePicker
extends MovePicker
## Picks a random move. Mostly useful as a mock picker for testing scenarios.


## Immediately picks a random move from [param moves].
func start(moves : Array[Move]) -> void:
	var move = moves.pick_random() as Move
	await move.execute()
	move_executed.emit(move)
