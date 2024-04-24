class_name AIPlayerRandom
extends AIPlayerBase

func _evaluate_moves(moves : Array[Move]) -> Move:
	return moves.pick_random()
