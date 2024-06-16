class_name InteractiveGameMoveSelector extends Node
## Allows player to select a move using input. For the available moves, the player can select
## a spot where he currently has pieces. Then the player can click a spot to move (corresponding to
## the available moves from the chosen starting spot). After both spots are picked, the
## corresponding move gets selected.
## Additionaly, it controls the highlighting effects during selection.


signal from_spot_selected(spot: Spot)
signal move_selected(move: GameMove)
signal selection_canceled

@export var highlight: GameMoveHighlight

@export var color_selectable := Color.MEDIUM_AQUAMARINE
@export var color_hovered := Color.AQUAMARINE
@export var color_selected := Color.DARK_TURQUOISE

var _moves: Array[GameMove] = []

var is_from_selected: bool = false


func _input(event):
	if is_from_selected and event.is_action_pressed("game_selection_cancel"):
		selection_canceled.emit()
		_start_from_selection()


func start_selection(moves: Array[GameMove]) -> void:
	_moves = moves.duplicate()
	_start_from_selection()


func stop_selection() -> void:
	is_from_selected = false
	for move in _moves:
		_clear_connections(move)
		highlight.clear_highlight(move)


func _start_from_selection() -> void:
	stop_selection() # cleanup before starting selection
	
	for move in _moves:
		if not move.from.input.hovered.is_connected(_on_from_hovered.bind(move.from)):
			move.from.input.hovered.connect(_on_from_hovered.bind(move.from))
		if not move.from.input.dehovered.is_connected(_on_from_dehovered.bind(move.from)):
			move.from.input.dehovered.connect(_on_from_dehovered.bind(move.from))
		
		if move.valid:
			if not move.from.input.clicked.is_connected(_on_from_selected.bind(move.from)):
				move.from.input.clicked.connect(_on_from_selected.bind(move.from))
			
			for piece in move.pieces_in_from:
				piece.highlight.set_active(true).set_color(color_selectable)


func _on_from_hovered(spot: Spot) -> void:
	var moves_from = _filter_moves_with_from(_moves, spot)
	# Sort invalid moves first, so valid moves are in a "higher layer" for highlighting
	# NOTE: this is due to overriding because moves share pieces/spots
	moves_from.sort_custom(func(a: GameMove, _b: GameMove): return not a.valid)
	for move in moves_from:
		GameEvents.move_hovered.emit(move)
		highlight.highlight(move, color_hovered)


func _on_from_dehovered(_spot: Spot) -> void:
	# Make sure all selectable moves are properly highlighted
	# NOTE: this is due to overriding because moves share pieces/spots
	for move in _moves:
		highlight.clear_highlight(move)
	for move in _moves:
		if move.valid:
			for piece in move.pieces_in_from:
				piece.highlight.set_active(true).set_color(color_selectable)


func _on_from_selected(spot: Spot) -> void:
	for move in _moves:
		_clear_connections(move)
		highlight.clear_highlight(move)
	
	var valid_moves = _filter_valid_moves(_filter_moves_with_from(_moves, spot))
	
	if GameManager.fast_move_enabled:
		var selected_move = valid_moves.front()
		move_selected.emit(selected_move)
	else:
		is_from_selected = true
		from_spot_selected.emit(spot)
		_start_to_selection(valid_moves)


func _start_to_selection(filtered_moves: Array[GameMove]) -> void:
	for move in filtered_moves:
		if not move.to.input.hovered.is_connected(_on_to_hovered.bind(move)):
			move.to.input.hovered.connect(_on_to_hovered.bind(move))
		if not move.to.input.dehovered.is_connected(_on_to_dehovered.bind(move)):
			move.to.input.dehovered.connect(_on_to_dehovered.bind(move))
		if not move.to.input.clicked.is_connected(_on_to_selected.bind(move)):
			move.to.input.clicked.connect(_on_to_selected.bind(move))
		
		highlight.highlight(move, color_selected)


func _on_to_hovered(move: GameMove) -> void:
	move.to.highlight.color = color_hovered


func _on_to_dehovered(move: GameMove) -> void:
	highlight.highlight(move, color_selected)


func _on_to_selected(selected_move: GameMove) -> void:
	stop_selection()
	move_selected.emit(selected_move)


func _clear_connections(move: GameMove) -> void:
	if not move.from or not move.to:
		return
	
	if move.from.input.hovered.is_connected(_on_from_hovered.bind(move.from)):
		move.from.input.hovered.disconnect(_on_from_hovered.bind(move.from))
	if move.from.input.dehovered.is_connected(_on_from_dehovered.bind(move.from)):
		move.from.input.dehovered.disconnect(_on_from_dehovered.bind(move.from))
	if move.from.input.clicked.is_connected(_on_from_selected.bind(move.from)):
		move.from.input.clicked.disconnect(_on_from_selected.bind(move.from))
	if move.to.input.hovered.is_connected(_on_to_hovered.bind(move)):
		move.to.input.hovered.disconnect(_on_to_hovered.bind(move))
	if move.to.input.dehovered.is_connected(_on_to_dehovered.bind(move)):
		move.to.input.dehovered.disconnect(_on_to_dehovered.bind(move))
	if move.to.input.clicked.is_connected(_on_to_selected.bind(move)):
		move.to.input.clicked.disconnect(_on_to_selected.bind(move))


func _filter_moves_with_from(moves: Array[GameMove], spot_from: Spot) -> Array[GameMove]:
	return moves.filter(func(move: GameMove): return move.from == spot_from)


func _filter_valid_moves(moves: Array[GameMove]) -> Array[GameMove]:
	return moves.filter(func(move: GameMove): return move.valid)
