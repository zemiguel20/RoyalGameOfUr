class_name AIPlayerRandom
extends AIPlayerBase

func _determine_next_move(moves : Array[Move]) -> Move:
	return moves.pick_random()
	# TODO: This hierarchy of AIPlayerBase/Advanced/Random could be removed,
	#		since you could just give the AIPlayer(Base) a 0% chance to pick
	#		the first or second move and a 100% chance to pick a random move.
	#		Code in that method would have to change slightly though.
