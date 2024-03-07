class_name AIPlayerBase
extends Node
## General component that imitates player actions and decides their move through a specific algorithm. 


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
	# TODO: optional shaking behaviour for AI
	if (_dice._roll_shaking_enabled):
		var clickEvent = InputEventMouseButton.new()
		clickEvent.pressed = true
		_dice._on_die_input_event(null, clickEvent, null, null, null)
		clickEvent.pressed = false
		await get_tree().create_timer(1.0).timeout
		_dice._input(clickEvent)
	else:
	# Wait for a moment, Ai should not have inhumane reaction speed.
		await _gamemode.get_tree().create_timer(0.5).timeout
		_dice.start_roll()
	
	
## Decides which piece to move, then make that piece move.
func make_move(moves : Array[Move]):
	var piece_to_move = _evaluate_moves(moves)
	_move_piece(piece_to_move)

	
## Function to signal a piece to move, mocking the 'clicking' behaviour of the player.
func _move_piece(piece : Piece):
	piece.on_ai_click()
