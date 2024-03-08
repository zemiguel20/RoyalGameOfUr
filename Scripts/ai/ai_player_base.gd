class_name AIPlayerBase
extends Node
## General component that imitates player actions and decides their move through a specific algorithm. 

@export_category("Rolling Behaviour")
## This variable is not used when dice shaking is disabled.
## The probability that the AI will shake the dice this turn, rather than throwing directly.
@export_range(0, 1) var shaking_probability = 1.0
## This variable is not used when dice shaking is disabled.
## Minimum duration the AI will shake the dice. 
@export_range(0.1,3.0) var min_shaking_duration: float = 0.3
## This variable is not used when dice shaking is disabled.
## Maximum duration the AI will shake the dice. 
@export_range(0.1,3.0) var max_shaking_duration: float = 2.0 

@export_category("Moving Behaviour")
## Minimum duration the AI will take to choose a move. 
## We simulate thinking time so that the AI feels more humane.
@export_range(0.1,3.0) var min_moving_duration: float = 0.3
## Maximum duration the AI will take to choose a move. 
## We simulate thinking time so that the AI feels more humane.
@export_range(0.1,3.0) var max_moving_duration: float = 2.0 


var _gamemode: Gamemode
var _board: Board
var _dice: Dice
var _player_id: General.PlayerID


## Virtual method that contains an algorithm for picking a move.
func _evaluate_moves(_moves : Array[Move]):
	pass


func setup(gamemode : Gamemode, player_id: General.PlayerID):
	_gamemode = gamemode
	_board = gamemode.board
	_dice = gamemode.dice
	_player_id = player_id
	

## Function to signal the dice to start rolling, mocking the 'clicking' behaviour of the player.
func roll():
	# Wait for a moment, Ai should not have inhumane reaction speed.
	await _gamemode.get_tree().create_timer(0.3).timeout
	
	var random = randf()
	var shake_this_turn = random <= shaking_probability
	
	var shaking_duration = 0
	if (_dice._roll_shaking_enabled and shake_this_turn):
		shaking_duration = randf_range(min_shaking_duration, max_shaking_duration)
		
	_dice.on_dice_click()
	await get_tree().create_timer(shaking_duration).timeout
	_dice.on_dice_release()
	
	
## Decides which piece to move, then make that piece move.
func make_move(moves : Array[Move]):
	var piece_to_move = _evaluate_moves(moves)
	_move_piece(piece_to_move)

	
## Function to signal a piece to move, mocking the 'clicking' behaviour of the player.
func _move_piece(piece : Piece):
	var thinking_duration = randf_range(min_moving_duration, max_moving_duration)
	await get_tree().create_timer(thinking_duration).timeout	
	piece.on_click()
