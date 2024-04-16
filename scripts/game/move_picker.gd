extends Node


@export var board: Board


var _moves: Array[Move]


func _on_move_phase_started(player: General.Player, roll_value: int):
	_moves = board.get_possible_moves(player, roll_value)
	for move in _moves:
		move.from.mouse_entered.connect(_on_move_hovered.bind(move))
		move.from.mouse_exited.connect(_on_move_dehovered.bind(move))


func _on_move_hovered(move: Move):
	move.from.highlight()
	move.to.highlight()

func _on_move_dehovered(move: Move):
	move.from.dehighlight()
	move.to.dehighlight()
