extends Node

enum Ruleset { FINKEL = 0, BLITZ = 1, TOURNAMENT = 2 }
var selected_ruleset: Ruleset

enum BoardLayout { REGULAR = 0, MASTERS = 1 }
var board_layout: BoardLayout

## Whether landing on a rosette should grant an extra turn.
var rosettes_grant_extra_turn: bool = true
## Whether standing on a rosette should protect a piece from being captured.
var rosettes_are_safe: bool = true
## Whether players should be allowed to stack their pieces on rosettes.
var rosettes_allow_stacking: bool = false
## Whether capturing a piece grants an extra turn.
var captures_grant_extra_turn: bool = false
## Whether pieces may be moved backwards.
var pieces_can_move_backwards: bool = false

## The number of pieces that will be used in the board game.
var num_pieces: int = 7:
	set(value):
		num_pieces = clampi(value, 1, 7)

## The number of dice that will be used in the board game.
var num_dice: int = 4:
	set(value):
		num_dice = clampi(value, 1, 5)


func on_previous_ruleset():
	select_ruleset(-1)


func on_next_ruleset():
	select_ruleset(+1)


func select_ruleset(delta: int):
	var current_ruleset_index = selected_ruleset
	var new_index = wrapi(current_ruleset_index + delta, 0, Ruleset.values().size())
	selected_ruleset = Ruleset.values()[new_index]
	
	match selected_ruleset:
		Ruleset.FINKEL:
			board_layout = BoardLayout.REGULAR
			rosettes_grant_extra_turn = true
			rosettes_are_safe = true
			rosettes_allow_stacking = false
			captures_grant_extra_turn = false
			pieces_can_move_backwards = false
			num_pieces = 7
			num_dice = 4
		Ruleset.BLITZ:
			board_layout = BoardLayout.MASTERS
			rosettes_grant_extra_turn = true
			rosettes_are_safe = false
			rosettes_allow_stacking = false
			captures_grant_extra_turn = true
			pieces_can_move_backwards = false
			num_pieces = 5
			num_dice = 4
		Ruleset.TOURNAMENT:
			board_layout = BoardLayout.MASTERS
			rosettes_grant_extra_turn = false
			rosettes_are_safe = true
			rosettes_allow_stacking = true
			captures_grant_extra_turn = false
			pieces_can_move_backwards = true
			num_pieces = 5
			num_dice = 4


func try_get_identified_ruleset() -> bool:
	if board_layout == BoardLayout.REGULAR and rosettes_grant_extra_turn and rosettes_are_safe \
	and not rosettes_allow_stacking and not captures_grant_extra_turn and not pieces_can_move_backwards \
	and num_pieces == 7 and num_dice == 4:
		selected_ruleset = Ruleset.FINKEL
		return true
	elif board_layout == BoardLayout.REGULAR and rosettes_grant_extra_turn and not rosettes_are_safe \
	and not rosettes_allow_stacking and captures_grant_extra_turn and not pieces_can_move_backwards \
	and num_pieces == 5 and num_dice == 4:
		selected_ruleset = Ruleset.BLITZ
		return true
	elif board_layout == BoardLayout.REGULAR and not rosettes_grant_extra_turn and rosettes_are_safe \
	and rosettes_allow_stacking and not captures_grant_extra_turn and pieces_can_move_backwards \
	and num_pieces == 5 and num_dice == 4:
		selected_ruleset = Ruleset.TOURNAMENT
		return true
	else:
		return false
