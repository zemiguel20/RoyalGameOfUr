class_name Ruleset extends Resource


@export var rosettes_are_safe: bool = false
@export var rosettes_give_extra_turn: bool = false
@export var rosettes_allow_stacking: bool = false
@export var captures_give_extra_turn: bool = false
@export var can_move_backwards: bool = false
@export var allow_skip_if_only_backwards: bool = false ## NOTE: this only works if can move backwards

@export_range(1, 7, 1) var num_pieces: int = 7
@export_range(1, 4, 1) var num_dice: int = 4

@export var board_layout: BoardLayout = preload("res://resources/rulesets/board_layouts/layout_finkel.tres")
