class_name MovePicker
extends Node


signal move_executed(move: Move)

var _moves: Array[Move] = []
var _selected_from_spot: Spot = null


func get_moves() -> Array[Move]:
	return _moves.duplicate()
	

func start_selection(moves: Array[Move]):
	_moves = moves.duplicate()
	_selected_from_spot = null
	
	for move in _moves:
		move.from.mouse_entered.connect(_on_from_spot_hovered.bind(move.from), CONNECT_REFERENCE_COUNTED)
		move.from.mouse_exited.connect(_on_from_spot_dehovered.bind(move.from), CONNECT_REFERENCE_COUNTED)
		move.from.selected.connect(_on_from_spot_selected.bind(move.from), CONNECT_REFERENCE_COUNTED)
		move.to.selected.connect(_on_to_spot_selected.bind(move.to), CONNECT_REFERENCE_COUNTED)
		
		_pre_selection_highlight()


func execute_move(move: Move):
	if not _moves.has(move):
		push_error("Trying to execute an unknown move")
		return
	
	await move.execute()
	move_executed.emit(move)


func end_selection():
	for move in _moves:
		move.from.mouse_entered.disconnect(_on_from_spot_hovered.bind(move.from))
		move.from.mouse_exited.disconnect(_on_from_spot_dehovered.bind(move.from))
		move.from.selected.disconnect(_on_from_spot_selected.bind(move.from))
		move.to.selected.disconnect(_on_to_spot_selected.bind(move.to))
		
		move.from.set_highlight(false)
		move.to.set_highlight(false)
		for piece in move.from.get_pieces():
			piece.set_highlight(false)
		for piece in move.to.get_pieces():
			piece.set_highlight(false)
	
	_selected_from_spot = null


func _on_move_phase_started(_player, moves: Array[Move]):
	start_selection(moves)


func _on_from_spot_hovered(spot: Spot):
	if not _selected_from_spot: # Hovering only works if there is no selection
		for move in _filter_moves(spot):
			move.from.set_highlight(true)
			move.to.set_highlight(true)


func _on_from_spot_dehovered(spot: Spot):
	if not _selected_from_spot: # Hovering only works if there is no selection
		for move in _filter_moves(spot):
			move.from.set_highlight(false)
			move.to.set_highlight(false)


func _on_from_spot_selected(spot: Spot):
	print("From clicked")
	
	if _selected_from_spot != null:
		return
	
	_selected_from_spot = spot
	
	if not Settings.can_move_backwards:
		var selected_move = _filter_moves(_selected_from_spot).front()
		end_selection()
		execute_move(selected_move)
	else:
		_post_selection_highlight()


func _on_to_spot_selected(spot: Spot):
	print("To clicked")
	
	if !_selected_from_spot or _filter_moves(_selected_from_spot, spot).is_empty():
		return
	
	var selected_move = _filter_moves(_selected_from_spot, spot).front()
	
	end_selection()
	execute_move(selected_move)


func _input(event):
	# Mouse right click to cancel selection
	if _selected_from_spot and event is InputEventMouseButton and event.is_pressed() \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
			_selected_from_spot = null
			_pre_selection_highlight()


func _pre_selection_highlight():
	for move in _moves:
		for piece in move.from.get_pieces():
			piece.set_highlight(true)
		
		move.from.set_highlight(false)
		move.to.set_highlight(false)


func _post_selection_highlight():
	for move in _moves:
		for piece in move.from.get_pieces():
			piece.set_highlight(false)
	
	for move in _filter_moves(_selected_from_spot):
		move.from.set_highlight(true, Color.GREEN)
		move.to.set_highlight(true, Color.GREEN)
		
		for piece in move.from.get_pieces():
			piece.set_highlight(true, Color.GREEN)


func _filter_moves(from: Spot = null, to: Spot = null) -> Array[Move]:
	var filtered = _moves
	
	if from != null:
		filtered = filtered.filter(func(move: Move): return move.from == from)
	
	if to != null:
		filtered = filtered.filter(func(move: Move): return move.to == to)
	
	return filtered
