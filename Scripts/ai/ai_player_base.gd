class_name AIPlayerBase
extends Node
## General component that imitates player actions and decides their move through a specific algorithm. 

var _gamemode : Gamemode
var _dice : Dice

## Virtual method that picks a move through an algorithm.
## Instead of the moves being a piece, we should have information about the move, so that it can be taking in with the evaluation.
func _evaluate_moves(moves : Array[Piece]):
	pass


# Note: It is more of an injection than a setup, so might rename
func setup(gamemode : Gamemode):
	_gamemode = gamemode
	_dice = gamemode.dice
	

## Function to signal the dice to start rolling, mocking the 'clicking' behaviour of the player.
func roll():
	# TODO: optional shaking behaviour for AI
	_dice.start_roll()
	
	
func make_move(moves : Array[Piece]):
	var piece_to_move = _evaluate_moves(moves)
	move_piece(piece_to_move)

	
## Function to signal a piece to move, mocking the 'clicking' behaviour of the player.
func move_piece(piece : Piece):
	piece.on_ai_click()
