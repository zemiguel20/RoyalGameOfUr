class_name InteractiveGameMoveSelector
extends GameMoveSelector
## Allows player to select a move through input. Normally, the player selects the spot
## with the pieces it wants to move, and the target spot to move to, while dragging the pieces.
## In fast mode, selecting the spot with the pieces to move will select the move immediately
## (if moving backwards is also possible, the the move forward is chosen).


signal selection_enabled
signal selection_disabled
signal from_spot_hovered(moves_from: Array[GameMove])


var _moves: Array[GameMove] = []
var _from_spots: Array[Spot] = []
var _to_spots: Array[Spot] = []
var _from_selected: Spot = null
var _piece_dragger: PieceDragger


func _ready() -> void:
	_piece_dragger = PieceDragger.new()
	add_child(_piece_dragger)


func start_selection(moves: Array[GameMove]) -> void:
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
	selection_enabled.emit()


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
	_from_selected = null
	_piece_dragger.stop(false)
	
	selection_disabled.emit()


func _on_from_hovered(from: Spot) -> void:
	if _from_selected:
		return
	
	var moves_from = _moves.filter(func(move: GameMove): return move.from == from)
	for move: GameMove in moves_from:
		_highlight_move_hovered(move)
	
	from_spot_hovered.emit(moves_from)


func _on_from_dehovered(from: Spot) -> void:
	if _from_selected:
		return
	
	_highlight_moves_selectable()


func _on_from_selected(from: Spot) -> void:
	if _from_selected:
		return
	
	var moves_from = _moves.filter(func(move: GameMove): return move.from == from)
	
	if Settings.fast_mode:
		stop()
		var selected_move = moves_from.front() as GameMove
		selected_move.execute(GameMove.AnimationType.SKIPPING)
		await selected_move.execution_finished
		move_selected.emit(selected_move)
	else:
		_from_selected = from
		
		_piece_dragger.start(_from_selected)
		
		for move in _moves:
			_clear_move_highlight(move)
			move.from.set_input_reading(false)
			move.to.set_input_reading(false)
		
		for move: GameMove in moves_from:
			_highlight_move_from_selected(move)
			move.to.set_input_reading(true)


func _input(event):
	if _from_selected and event.is_action_pressed("cancel_selection"):
		_cancel_selection()


func _cancel_selection() -> void:
	_piece_dragger.stop()
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
		).front() as GameMove
	
	stop()
	selected_move.execute(GameMove.AnimationType.DIRECT)
	await selected_move.execution_finished
	move_selected.emit(selected_move)


func _highlight_moves_selectable() -> void:
	for move in _moves:
		_clear_move_highlight(move)
	
	for spot in _from_spots:
		var color = _get_selectable_color(spot)
		for piece in spot.pieces:
			piece.enable_highlight(color)


func _get_selectable_color(spot: Spot) -> Color:
	var moves_from = _moves.filter(func(move: GameMove): return move.from == spot)
	for move in moves_from:
		var to_color = _get_to_spot_color(move)
		var neutral_color = General.get_highlight_color(General.HighlightType.NEUTRAL)
		var has_special_outcome = to_color != neutral_color
		if has_special_outcome:
			return General.get_highlight_color(General.HighlightType.SELECTABLE_SPECIAL)
	
	return General.get_highlight_color(General.HighlightType.SELECTABLE)


func _highlight_move_hovered(move: GameMove) -> void:
	_highlight_move(move)
	
	var hovered_color = General.get_highlight_color(General.HighlightType.HOVERED)
	move.from.enable_highlight(hovered_color)


func _highlight_move_from_selected(move: GameMove) -> void:
	_highlight_move(move)
	
	var selected_color = General.get_highlight_color(General.HighlightType.SELECTED)
	move.from.enable_highlight(selected_color)
	for piece in move.pieces_in_from:
		piece.enable_highlight(selected_color)
	
	move.to.enable_highlight(General.get_highlight_color(General.HighlightType.SELECTABLE))
