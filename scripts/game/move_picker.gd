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
	
	# Enable selection
	for from_spot: Spot in _moves_dict:
		from_spot.highlight_pieces()
		from_spot.mouse_entered.connect(_on_spot_hovered.bind(from_spot))
		from_spot.mouse_exited.connect(_on_spot_dehovered.bind(from_spot))
		from_spot.selected.connect(_on_from_spot_selected.bind(from_spot))


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
	
	# Disable selection
	for from_spot: Spot in _moves_dict:
		if from_spot != spot:
			from_spot.dehighlight_pieces()
		from_spot.mouse_entered.disconnect(_on_spot_hovered.bind(from_spot))
		from_spot.mouse_exited.disconnect(_on_spot_dehovered.bind(from_spot))
		from_spot.selected.disconnect(_on_from_spot_selected.bind(from_spot))
	
	if not Settings.can_move_backwards:
		_on_spot_dehovered(spot) # Force dehighlight
		spot.dehighlight_pieces()
		var move = _moves_dict[spot].front() as Move
		await move.execute()
		move_executed.emit(move)
	else:
		for move in _moves_dict[spot] as Array[Move]:
			move.to.selected.connect(_on_to_spot_selected.bind(move))


func _on_to_spot_selected(selected_move: Move):
	# Disable selection
	for move in _moves_dict[selected_move.from] as Array[Move]:
		move.to.selected.disconnect(_on_to_spot_selected.bind(move))
		
		move.to.dehighlight_base()
		move.from.dehighlight_base()
		move.from.dehighlight_pieces()
	
	await selected_move.execute()
	move_executed.emit(selected_move)
