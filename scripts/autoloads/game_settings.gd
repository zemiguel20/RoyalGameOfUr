extends Node


var can_stack_in_safe_spot: bool = false
var num_pieces: int = 7:
	set(value):
		num_pieces = clampi(num_pieces, 1, 7)
var can_move_backwards: bool = false
