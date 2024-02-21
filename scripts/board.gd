class_name Board
extends Node
## Manages the state of the board. It stores in which spot the pieces of each player are.
## It allows queries to the state of the board, and also moves the pieces.


## Initialize the board
func setup():
	# TODO: implement
	pass


## Returns the list of pieces of the given [param player_id] that can be moved in [param roll] steps.
## If the list is empty, then the player has no possible moves.
func legal_moves(player_id: int, roll: int) -> Array[Piece]:
	# TODO: implement
	return []


## Moves [param piece] a number of steps equal to [param roll]. Returns a feedback code depending on the result on the move.
## [br]
## 0 - Normal/Nothing [br]
## 1 - Gets extra roll [br]
## 2 - Won the game [br]
func move(piece: Piece, roll: int) -> int:
	# TODO: implement movement
	return false
