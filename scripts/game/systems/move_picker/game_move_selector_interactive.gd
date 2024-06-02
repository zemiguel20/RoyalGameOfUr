class_name InteractiveGameMoveSelector extends Node
## Allows player to select a move using input. For the available moves, the player can select
## a spot where he currently has pieces. Then the player can click a spot to move (corresponding to
## the available moves from the chosen starting spot). After both spots are picked, the
## corresponding move gets executed.
##
## Additionaly, it controls the highlighting effects during selection, and also makes the selected
## pieces follow the cursor.


signal from_spot_selected(spot: Spot)
signal move_selected(move: GameMove)
signal selection_canceled

@export var highlight: GameMoveHighlight

var _moves: Array[GameMove] = []

var is_from_selected: bool = false


func _input(event):
	if is_from_selected and event.is_action_pressed("game_spot_selection_cancel"):
		selection_canceled.emit()
		_clear_state()
		_start_from_selection()


func start_selection(moves: Array[GameMove]):
	_moves = moves.duplicate()
	_start_from_selection()


func _start_from_selection() -> void:
	for move in _moves:
		# Connect hover highlight to input, and 'from' selection
		if not move.from.mouse_entered.is_connected(highlight.highlight_hovered.bind(move)):
			move.from.mouse_entered.connect(highlight.highlight_hovered.bind(move))
		if not move.from.mouse_entered.is_connected(highlight.highlight_selectable.bind(move)):
			move.from.mouse_exited.connect(highlight.highlight_selectable.bind(move))
		if not move.from.selected.is_connected(_on_from_selected.bind(move.from)):
			move.from.selected.connect(_on_from_selected.bind(move.from))
		
		highlight.highlight_selectable(move)


func _on_from_selected(spot: Spot):
	_clear_state()
	
	var moves_from = _moves.filter(func(move: GameMove): return move.from == spot)
	
	if not Settings.can_move_backwards:
		var selected_move = moves_from.front()
		move_selected.emit(selected_move)
	else:
		is_from_selected = true
		_start_to_selection(moves_from)


func _start_to_selection(moves_from: Array[GameMove]) -> void:
	for move in moves_from:
		if not move.to.selected.is_connected(_on_to_selected.bind(move)):
			move.to.selected.connect(_on_to_selected.bind(move))
		
		highlight.highlight_selected(move)


func _on_to_selected(move: GameMove):
	_clear_state()
	move_selected.emit(move)


func _clear_state():
	for move in _moves:
		# Disconnect callbacks from all input
		if move.from.mouse_entered.is_connected(highlight.highlight_hovered.bind(move)):
			move.from.mouse_entered.disconnect(highlight.highlight_hovered.bind(move))
		if move.from.mouse_exited.is_connected(highlight.highlight_selectable.bind(move)):
			move.from.mouse_exited.disconnect(highlight.highlight_selectable.bind(move))
		if move.from.selected.is_connected(_on_from_selected.bind(move.from)):
			move.from.selected.disconnect(_on_from_selected.bind(move.from))
		if move.to.selected.is_connected(_on_to_selected.bind(move.to)):
			move.to.selected.disconnect(_on_to_selected.bind(move.to))
		
		highlight.clear_highlight(move)
	
	is_from_selected = false
