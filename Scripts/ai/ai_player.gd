class_name AIPlayer
extends Node

var _gamemode : Gamemode
var _dice : Dice

func setup(gamemode : Gamemode):
	_gamemode = gamemode
	_dice = gamemode.dice
	

func roll():
	_dice.roll()
	
	
# List of moves
func evaluate_moves(moves):
	var move = moves.get_random()
	move_piece(move.piece)
	
	
func move_piece(piece : Piece):
	piece.on_ai_click()
