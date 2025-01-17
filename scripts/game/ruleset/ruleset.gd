class_name Ruleset
extends Resource


@export var name: String = "Default"

@export var rosettes_are_safe: bool = false
@export var rosettes_give_extra_turn: bool = false
@export var rosettes_allow_stacking: bool = false
@export var captures_give_extra_turn: bool = false
@export var can_move_backwards: bool = false

@export_range(1, 7, 1) var num_pieces: int = 7
@export_range(1, 4, 1) var num_dice: int = 4

@export var board_layout: BoardLayout = preload("res://resources/rulesets/board_layouts/layout_finkel.tres")


func to_dict() -> Dictionary:
	var dict = {
		"name" : name,
		"rosettes_are_safe" : rosettes_are_safe,
		"rosettes_give_extra_turn" : rosettes_give_extra_turn,
		"rosettes_allow_stacking" : rosettes_allow_stacking,
		"captures_give_extra_turn" : captures_give_extra_turn,
		"can_move_backwards" : can_move_backwards,
		"num_pieces" : num_pieces,
		"num_dice" : num_dice,
		"board_layout" : board_layout.name
	}
	
	return dict
