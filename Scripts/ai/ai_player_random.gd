class_name AIPlayerRandom
extends AIPlayerBase

func _evaluate_moves(moves : Array[Piece]):
    return moves.pick_random()