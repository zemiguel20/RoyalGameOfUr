class_name GameMoveSelector
extends Node
## Abstract class for move selectors.


signal move_selected(move: GameMove)


func start_selection(moves: Array[GameMove]) -> void:
	push_warning("Using abstract method. Implement method in concrete class.")
