extends Node


signal move_executed(move: Move)

@export var board: Board

# Using a dictionary to organize moves, grouping them by 'from' spot.
# 'from' spot -> Array [ forward move, backward move ]
# This makes it easier to manage signal connections.
var _moves_dict: Dictionary


func _on_move_phase_started(player: General.Player, roll_value: int):
	# Build dictionary
	var moves = board.get_possible_moves(player, roll_value)
	_moves_dict = {}
	for move in moves:
		if not _moves_dict.has(move.from):
			_moves_dict[move.from] = []
		
		(_moves_dict[move.from] as Array).append(move)
	
	_enable_from_selection()


func _enable_from_selection():
	for from_spot: Spot in _moves_dict:
		from_spot.highlight_pieces()
		from_spot.mouse_entered.connect(_on_spot_hovered.bind(from_spot))
		from_spot.mouse_exited.connect(_on_spot_dehovered.bind(from_spot))
		from_spot.selected.connect(_on_from_spot_selected.bind(from_spot))


func _disable_from_selection():
	for from_spot: Spot in _moves_dict:
		from_spot.dehighlight_pieces()
		from_spot.mouse_entered.disconnect(_on_spot_hovered.bind(from_spot))
		from_spot.mouse_exited.disconnect(_on_spot_dehovered.bind(from_spot))
		from_spot.selected.disconnect(_on_from_spot_selected.bind(from_spot))


func _on_spot_hovered(spot: Spot):
	for move in (_moves_dict[spot] as Array[Move]):
		move.from.highlight_base()
		move.to.highlight_base()


func _on_spot_dehovered(spot: Spot):
	for move in (_moves_dict[spot] as Array[Move]):
		move.from.dehighlight_base()
		move.to.dehighlight_base()


func _on_from_spot_selected(spot: Spot):
	print("click")
	_disable_from_selection()
	
	if not Settings.can_move_backwards:
		_on_spot_dehovered(spot) # Force dehighlight
		var move = _moves_dict[spot].front() as Move
		await move.execute()
		move_executed.emit(move)
	else:
		# TODO: Implement distinction between only forward selection
		push_error("No support for backwards selection yet")
