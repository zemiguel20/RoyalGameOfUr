class_name MovePicker
extends Node


signal move_executed(move: Move)

var _moves : Array[Move] = []
var _selected_from_spot : Spot = null
var _selected_to_spot : Spot = null


func _input(event):
	# Mouse right click to cancel selection
	if _selected_from_spot and event is InputEventMouseButton and event.is_pressed() \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
			_selected_from_spot = null
			_pre_from_selection_highlight()


func start(moves: Array[Move]):
	_moves = moves.duplicate()
	_selected_from_spot = null
	_connect_signals()
	_pre_from_selection_highlight()

#region Signal callbacks
func _connect_signals():
	for move in _moves:
		move.from.mouse_entered.connect(_on_from_hovered.bind(move.from), CONNECT_REFERENCE_COUNTED)
		move.from.mouse_exited.connect(_on_from_dehovered.bind(move.from), CONNECT_REFERENCE_COUNTED)
		move.from.selected.connect(_on_from_selected.bind(move.from), CONNECT_REFERENCE_COUNTED)
		move.to.selected.connect(_on_to_selected.bind(move.to), CONNECT_REFERENCE_COUNTED)


func _disconnect_signals():
	for move in _moves:
		move.from.mouse_entered.disconnect(_on_from_hovered.bind(move.from))
		move.from.mouse_exited.disconnect(_on_from_dehovered.bind(move.from))
		move.from.selected.disconnect(_on_from_selected.bind(move.from))
		move.to.selected.disconnect(_on_to_selected.bind(move.to))


func _on_from_hovered(spot: Spot):
	# Hovering only works if there is no selection
	if _selected_from_spot:
		return
	
	for move in _filter_moves(spot):
		_set_highlight_move_spots(move, true)
		_add_path_highlighter(move)


func _on_from_dehovered(spot: Spot):
	# Hovering only works if there is no selection
	if _selected_from_spot:
		return
	
	for move in _filter_moves(spot):
		_set_highlight_move_spots(move, false)
	
	_clear_path_highlighters()


func _on_from_selected(spot: Spot):
	print("From clicked")
	
	if _selected_from_spot:
		return
	
	_selected_from_spot = spot
	
	_clear_all_highlighting()
	
	if not Settings.can_move_backwards:
		_execute_move()
	else:
		_post_from_selection_highlight()


func _on_to_selected(spot: Spot):
	print("To clicked")
	
	var move_not_exists = _filter_moves(_selected_from_spot, spot).is_empty()
	if not _selected_from_spot or move_not_exists:
		return
	
	_selected_to_spot = spot
	
	_execute_move()
#endregion


#region Moves
func _filter_moves(from: Spot = null, to: Spot = null) -> Array[Move]:
	var filtered = _moves
	
	if from != null:
		filtered = filtered.filter(func(move: Move): return move.from == from)
	
	if to != null:
		filtered = filtered.filter(func(move: Move): return move.to == to)
	
	return filtered


func _execute_move():
	var selected_move = _filter_moves(_selected_from_spot, _selected_to_spot).front() as Move
	
	_disconnect_signals()
	_clear_all_highlighting()
	_selected_from_spot = null
	_selected_to_spot = null
	
	await selected_move.execute()
	move_executed.emit(selected_move)
#endregion


#region Highlighting
func _pre_from_selection_highlight():
	for move in _moves:
		_set_highlight_move_pieces(move, true, Color.WHITE, Color(0,0,0,0))
		_set_highlight_move_spots(move, false)
	
	_clear_path_highlighters()


func _post_from_selection_highlight():
	for move in _moves:
		_set_highlight_move_pieces(move, false)
	
	for move in _filter_moves(_selected_from_spot):
		_set_highlight_move_spots(move, true, Color.GREEN)
		_set_highlight_move_pieces(move, true, Color.GREEN)
		_add_path_highlighter(move)


func _clear_all_highlighting():
	for move in _moves:
		_set_highlight_move_spots(move, false)
		_set_highlight_move_pieces(move, false)
	_clear_path_highlighters()


func _add_path_highlighter(move : Move):
	var move_path_highlight = preload("res://scenes/move_path_highlight.tscn")
	var path = move_path_highlight.instantiate()
	path.curve.clear_points()
	path.curve.add_point(move.from.global_position)
	path.curve.add_point(move.to.global_position)
	add_child(path)


func _clear_path_highlighters():
	for path in get_children():
		path.queue_free()


func _set_highlight_move_pieces(move : Move, enabled : bool, from_color : Color = Color.WHITE, \
to_color : Color = Color.WHITE):
	for piece in move.from.get_pieces():
		piece.set_highlight(enabled, from_color)
	for piece in move.to.get_pieces():
		piece.set_highlight(enabled, to_color)


func _set_highlight_move_spots(move : Move, enabled : bool, color : Color = Color.WHITE):
	move.from.set_highlight(enabled, color)
	move.to.set_highlight(enabled, color)
#endregion
