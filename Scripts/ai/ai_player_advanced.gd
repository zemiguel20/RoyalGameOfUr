class_name AIPlayerAdvanced
extends AIPlayerBase

## Dictionary with key: Move and value: float
## When evaluating every move, the dictionary will reset and add the final scores to each .
#var _move_scores : Dictionary

## Note: This function is currently a sort of mockup/pseudocode for how it should be.
func _evaluate_moves(moves : Array[Move]) -> Piece:
	var best_move = null
	var best_move_score = 0		# Lowest score by default
	
	for move in moves:
		var score = _evaluate_move(move)
		if (score > best_move_score):
			best_move = move
	
	return best_move


# Very temporary, or perhaps for a very medium AI
func _evaluate_move(move: Move) -> float:
	var score = 0
	
	if (move.is_capture):
		return 1
	elif (move.is_safe):
		return 0.5
	else:
		return 0.1
