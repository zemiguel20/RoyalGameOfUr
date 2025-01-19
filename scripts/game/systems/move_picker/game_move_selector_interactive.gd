class_name InteractiveGameMoveSelector
extends Node
## Controls the interaction process for selecting a move.

signal move_selected(move: GameMove)

var _moves: Array[GameMove] = []
var _from_spots: Array[Spot] = []
var _to_spots: Array[Spot] = []
var _move_path_highlighter_dict: Dictionary = {} # Move -> Path Highlighter
var _from_selected: Spot = null


func _input(event):
	if _from_selected and event.is_action_pressed("cancel_selection"):
		_cancel_selection()


func start(moves: Array[GameMove]) -> void:
	_moves.assign(moves)
	
	for move in _moves:
		if not _from_spots.has(move.from):
			_from_spots.append(move.from)
		if not _to_spots.has(move.to):
			_to_spots.append(move.to)
	
	for spot in _from_spots:
		spot.set_input_reading(true)
		spot.mouse_entered.connect(_on_from_hovered.bind(spot))
		spot.mouse_exited.connect(_on_from_dehovered.bind(spot))
		spot.clicked.connect(_on_from_selected.bind(spot))
	
	for spot in _to_spots:
		spot.mouse_entered.connect(_on_to_hovered.bind(spot))
		spot.mouse_exited.connect(_on_to_dehovered.bind(spot))
		spot.clicked.connect(_on_to_selected.bind(spot))
	
	_highlight_moves_selectable()


# WARNING: this function cleans up, so it should be called last
func stop() -> void:
	for move in _moves:
		_clear_move_highlight(move)
	
	for spot in _from_spots:
		spot.set_input_reading(false)
		spot.mouse_entered.disconnect(_on_from_hovered.bind(spot))
		spot.mouse_exited.disconnect(_on_from_dehovered.bind(spot))
		spot.clicked.disconnect(_on_from_selected.bind(spot))
	
	for spot in _to_spots:
		spot.set_input_reading(false)
		spot.mouse_entered.disconnect(_on_to_hovered.bind(spot))
		spot.mouse_exited.disconnect(_on_to_dehovered.bind(spot))
		spot.clicked.disconnect(_on_to_selected.bind(spot))
	
	_moves.clear()
	_from_spots.clear()
	_to_spots.clear()
	_move_path_highlighter_dict.clear()
	_from_selected = null


func _on_from_hovered(from: Spot) -> void:
	if _from_selected:
		return
	
	var moves_from = _moves.filter(func(move: GameMove): return move.from == from)
	for move: GameMove in moves_from:
		_highlight_move_hovered(move)


func _on_from_dehovered(from: Spot) -> void:
	if _from_selected:
		return
	
	_highlight_moves_selectable()


func _on_from_selected(from: Spot) -> void:
	var moves_from = _moves.filter(func(move: GameMove): return move.from == from)
	
	if Settings.fast_mode:
		stop()
		var selected_move = moves_from.front()
		move_selected.emit(selected_move)
	else:
		_from_selected = from
		
		# TODO: Enable floating pieces
		
		for move in _moves:
			_clear_move_highlight(move)
			move.from.set_input_reading(false)
			move.to.set_input_reading(false)
		
		for move: GameMove in moves_from:
			_highlight_move_from_selected(move)
			move.to.set_input_reading(true)


func _cancel_selection() -> void:
	_from_selected = null
	
	for spot in _to_spots:
		spot.set_input_reading(false)
		
	for spot in _from_spots:
		spot.set_input_reading(true)
	_highlight_moves_selectable()


func _on_to_hovered(to: Spot) -> void:
	if not _from_selected:
		return
	
	to.enable_highlight(General.get_highlight_color(General.HighlightType.HOVERED))


func _on_to_dehovered(to: Spot) -> void:
	if not _from_selected:
		return
	
	to.enable_highlight(General.get_highlight_color(General.HighlightType.SELECTABLE))


func _on_to_selected(to: Spot) -> void:
	if not _from_selected:
		return
	
	var selected_move = _moves.filter( \
			func(move: GameMove): return move.from == _from_selected and move.to == to \
		).front()
	
	stop()
	move_selected.emit(selected_move)


# Creates a path highlighter for the given move. If the move already has an associated
# path highlighter, returns that one instead.
func _get_path_highlighter(move: GameMove) -> ScrollingTexturePath3D:
	if _move_path_highlighter_dict.has(move):
		return _move_path_highlighter_dict[move]
	
	var path_highlight_prebab = preload("res://scenes/game/systems/move_picker/path_highlight.tscn")
	var path = path_highlight_prebab.instantiate() as ScrollingTexturePath3D
	
	path.curve.clear_points()
	
	# Add all spots to the curve
	# Midpoints forming an arch to fix clipping through board
	for i in move.full_path.size():
		var spot = move.full_path[i]
		path.curve.add_point(spot.global_position)
		
		if i < move.full_path.size() - 1:
			var next_spot = move.full_path[i + 1]
			var midpoint = spot.global_position.lerp(next_spot.global_position, 0.5)
			midpoint.y = maxf(spot.global_position.y, next_spot.global_position.y) + 0.002
			path.curve.add_point(midpoint)
	
	# Save path
	_move_path_highlighter_dict[move] = path
	add_child(path)
	
	return path


func _get_to_spot_color(move: GameMove) -> Color:
	if move.to_is_end_of_track:
		return General.get_highlight_color(General.HighlightType.END)
	elif move.knocks_opponent_out:
		return General.get_highlight_color(General.HighlightType.KO)
	elif move.to.is_rosette:
		return General.get_highlight_color(General.HighlightType.SAFE)
	else:
		return General.get_highlight_color(General.HighlightType.NEUTRAL)


func _clear_move_highlight(move: GameMove) -> void:
	var path_highlight = _get_path_highlighter(move)
	path_highlight.hide()
	
	move.from.disable_highlight()
	for piece in move.pieces_in_from:
		piece.disable_highlight()
	
	move.to.disable_highlight()
	for piece in move.pieces_in_to:
		piece.disable_highlight()


func _highlight_moves_selectable() -> void:
	for move in _moves:
		_clear_move_highlight(move)
	for spot in _from_spots:
		for piece in spot.pieces:
			piece.enable_highlight(General.get_highlight_color(General.HighlightType.SELECTABLE))


func _highlight_move_hovered(move: GameMove) -> void:
	var hovered_color = General.get_highlight_color(General.HighlightType.HOVERED)
	move.from.enable_highlight(hovered_color)
	for piece in move.pieces_in_from:
		piece.enable_highlight(hovered_color)
	
	var to_color = _get_to_spot_color(move)
	
	move.to.enable_highlight(to_color)
	for piece in move.pieces_in_to:
		piece.enable_highlight(to_color)
	
	var path_highlight = _get_path_highlighter(move)
	path_highlight.color_modulate = to_color
	path_highlight.show()


func _highlight_move_from_selected(move: GameMove) -> void:
	var selected_color = General.get_highlight_color(General.HighlightType.SELECTED)
	move.from.enable_highlight(selected_color)
	for piece in move.pieces_in_from:
		piece.enable_highlight(selected_color)
	
	move.to.enable_highlight(General.get_highlight_color(General.HighlightType.SELECTABLE))
	
	var to_color = _get_to_spot_color(move)
	
	for piece in move.pieces_in_to:
		piece.enable_highlight(to_color)
	
	var path_highlight = _get_path_highlighter(move)
	path_highlight.color_modulate = to_color
	path_highlight.show()
