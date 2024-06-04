class_name AIPlayerBase
extends Node
## General component that imitates player actions and decides their move through a specific algorithm. 

signal move_executed(move: Move)

@export_category("Setup")
@export var _player_id: General.Player
@export var _dice: Dice
@export var _move_picker: MovePicker

@export_category("Rolling Behaviour")
var _are_actions_enabled: bool = true
var _waiting_for_dice_roll: bool
## This variable is not used when dice shaking is disabled.
## The probability that the AI will shake the dice this turn, rather than throwing directly.
@export_range(0, 1) var shaking_probability = 1.0
## This variable is not used when dice shaking is disabled.
## Minimum duration the AI will shake the dice. 
@export_range(0.1,3.0) var min_shaking_duration: float = 0.3
## This variable is not used when dice shaking is disabled.
## Maximum duration the AI will shake the dice. 
@export_range(0.1,3.0) var max_shaking_duration: float = 2.0 
@export_range(0.1,3.0) var rolling_delay: float = 0.5

@export_category("Moving Behaviour")
var _waiting_for_piece_move: bool
var _cached_moves
## Minimum duration the AI will take to choose a move. 
## We simulate thinking time so that the AI feels more humane.
@export_range(0.1,3.0) var min_moving_duration: float = 0.3
## Maximum duration the AI will take to choose a move. 
## We simulate thinking time so that the AI feels more humane.
@export_range(0.1,3.0) var max_moving_duration: float = 2.0 


## Virtual method that contains an algorithm for picking a move.
func _evaluate_moves(_moves : Array[Move]):
	pass


func _disable_rolling():
	_are_actions_enabled = false


func _enable_rolling():
	_are_actions_enabled = true
	
	if _waiting_for_dice_roll:
		_waiting_for_dice_roll = false
		_on_roll_phase_started(General.Player.TWO)
	elif _waiting_for_piece_move:
		_waiting_for_piece_move = false
		_on_move_phase_started(General.Player.TWO, _cached_moves)


func _on_roll_phase_started(player: General.Player):
	if player == _player_id:
			if not _dice.is_ready:
				await _dice.dice_transfer_finished
				
			_dice.disable_selection()
				
			if _are_actions_enabled:
				roll()
			else:
				_waiting_for_dice_roll = true


func _on_move_phase_started(player: General.Player, moves: Array[Move]):
	if player == _player_id:
		if _are_actions_enabled:
			var best_move = _evaluate_moves(moves)
			# HACK disable the selection
			_move_picker.end_selection()
			perform_move(best_move)
		else:
			_cached_moves = moves.duplicate()
			_waiting_for_piece_move = true


## Function to signal the dice to start rolling, mocking the 'clicking' behaviour of the player.
func roll():
	# Wait for a moment, Ai should not have inhumane reaction speed.
	await get_tree().create_timer(rolling_delay).timeout
	
	var random = randf()
	var shake_this_turn = random <= shaking_probability
	
	var shaking_duration = 0
	if (_dice._roll_shaking_enabled and shake_this_turn):
		shaking_duration = randf_range(min_shaking_duration, max_shaking_duration)
		
	_dice.on_dice_click()
	await get_tree().create_timer(shaking_duration).timeout
	_dice.on_dice_release()
	
	
## Decides which piece to move, then make that piece move.
func perform_move(move: Move):
	var thinking_duration = randf_range(min_moving_duration, max_moving_duration)
	await get_tree().create_timer(thinking_duration).timeout	
	await _move_picker.execute_move(move)
