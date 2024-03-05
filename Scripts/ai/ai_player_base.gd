class_name AIPlayerBase
extends Node
## General component that imitates player actions and decides their move through a specific algorithm. 


var _gamemode: Gamemode
var _board: Board
var _dice: Dice
var _player_id: General.PlayerID


## Virtual method that picks a move through an algorithm.
## Instead of the moves being a piece, we should have information about the move, so that it can be taking in with the evaluation.
func _evaluate_moves(_moves : Array[Move]):
	pass


# Note: It is more of an injection than a setup, so might rename
func setup(gamemode : Gamemode, player_id: General.PlayerID):
	_gamemode = gamemode
	_board = gamemode.board
	_dice = gamemode.dice
	_player_id = player_id

## Function to signal the dice to start rolling, mocking the 'clicking' behaviour of the player.
func roll():
	# TODO: optional shaking behaviour for AI
	_dice.start_roll()
	
	
## Decides which piece to move, then make that piece move.
func make_move(moves : Array[Move]):
	var piece_to_move = _evaluate_moves(moves)
	_move_piece(piece_to_move)

	
## Function to signal a piece to move, mocking the 'clicking' behaviour of the player.
func _move_piece(piece : Piece):
	piece.on_ai_click()
