extends Node


var can_stack_in_safe_spot: bool = false
## The number of pieces that will be used in the board game.
var num_pieces: int = 7:
	set(value):
		num_pieces = clampi(num_pieces, 1, 7)
## The number of dice that will be used in the board game.
var num_dice: int = 5:
	set(value):
		num_pieces = clampi(num_pieces, 1, 5)
var can_move_backwards: bool = false
