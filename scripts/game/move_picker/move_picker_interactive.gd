class_name InteractiveMovePicker
extends MovePicker
## Allows player to select a move using input. For the available moves, the player can select
## a spot where he currently has pieces. Then the player can click a spot to move (corresponding to
## the available moves from the chosen starting spot). After both spots are picked, the
## corresponding move gets executed.
##
## Additionaly, it controls the highlighting effects during selection, and also makes the selected
## pieces follow the cursor.


enum State {IDLE, FROM_SELECT, TO_SELECT}

@export var board_surface_y: float = 0.35

var _state : State = State.IDLE
var _moves : Array[Move] = []
var _selected_from_spot : Spot = null
var _selected_to_spot : Spot = null
var _pieces_to_drag : Array[Piece] = [] # Easier access to pieces while dragging them

@onready var move_highlighter = $MoveHighlighterComponent as MoveHighlighterComponent


func start(moves : Array[Move]):
	_moves = moves.duplicate()
	_change_state(State.FROM_SELECT)


func _process(delta):
	if not _pieces_to_drag.is_empty():
		_update_dragged_pieces(delta)


func _input(event):
	if _state == State.TO_SELECT and event.is_action_pressed("game_spot_selection_cancel"):
		_reset_dragged_pieces()
		_change_state(State.FROM_SELECT)


func _change_state(new_state : State):
	_clear_state()
	_state = new_state
	_setup_state()


func _setup_state():
	match _state:
		State.FROM_SELECT:
			# Connect signals for input interaction
			for move in _moves:
				var spot = move.from
				if not spot.mouse_entered.is_connected(_on_from_hovered.bind(spot)):
					spot.mouse_entered.connect(_on_from_hovered.bind(spot))
				if not spot.mouse_entered.is_connected(_on_from_dehovered.bind(spot)):
					spot.mouse_exited.connect(_on_from_dehovered.bind(spot))
				if not spot.selected.is_connected(_on_from_selected.bind(spot)):
					spot.selected.connect(_on_from_selected.bind(spot))
			
			# Highlight pieces
			for move in _moves:
				move_highlighter.highlight_selectable_pieces(move)
	
		State.TO_SELECT:
			# Connect signals for input interaction
			var filtered_moves = _filter_moves(_selected_from_spot)
			for move in filtered_moves:
				var spot = move.to
				if not spot.selected.is_connected(_on_to_selected.bind(spot)):
					spot.selected.connect(_on_to_selected.bind(spot))
			
			# Highlight moves
			for move in filtered_moves:
				move_highlighter.highlight_pieces_selected(move)
			
			# Starts dragging selected pieces
			_pieces_to_drag = _filter_moves(_selected_from_spot).front().pieces_in_from.duplicate()
		_:
			pass


func _clear_state():
	# Disconnect all input interaction from all spots
	for move in _moves:
		var spot = move.from
		if spot.mouse_entered.is_connected(_on_from_hovered.bind(spot)):
			spot.mouse_entered.disconnect(_on_from_hovered.bind(spot))
		if spot.mouse_exited.is_connected(_on_from_dehovered.bind(spot)):
			spot.mouse_exited.disconnect(_on_from_dehovered.bind(spot))
		if spot.selected.is_connected(_on_from_selected.bind(spot)):
			spot.selected.disconnect(_on_from_selected.bind(spot))
		
		spot = move.to
		if spot.selected.is_connected(_on_to_selected.bind(spot)):
			spot.selected.disconnect(_on_to_selected.bind(spot))
	
	# Clear all highlighting
	for move in _moves:
		move_highlighter.clear_highlight(move)
	
	# Stops dragging pieces
	_pieces_to_drag.clear()


func _on_from_hovered(from : Spot):
	for move in _filter_moves(from):
		move_highlighter.highlight_move_preview(move)


func _on_from_dehovered(from : Spot):
	for move in _filter_moves(from):
		move_highlighter.highlight_selectable_pieces(move)


func _on_from_selected(spot: Spot):
	print("From clicked")
	
	_selected_from_spot = spot
	
	if not Settings.can_move_backwards:
		_finalize_selection()
	else:
		_change_state(State.TO_SELECT)


func _on_to_selected(spot: Spot):
	print("To clicked")
	
	_selected_to_spot = spot
	
	_finalize_selection()


func _filter_moves(from: Spot = null, to: Spot = null) -> Array[Move]:
	var filtered = _moves
	
	if from != null:
		filtered = filtered.filter(func(move: Move): return move.from == from)
	
	if to != null:
		filtered = filtered.filter(func(move: Move): return move.to == to)
	
	return filtered


func _finalize_selection():
	var selected_move = _filter_moves(_selected_from_spot, _selected_to_spot).front() as Move
	
	_change_state(State.IDLE)
	
	var animation = General.MoveAnim.LINE if Settings.can_move_backwards else General.MoveAnim.ARC
	selected_move.execute(animation)
	await selected_move.execution_finished
	move_executed.emit(selected_move)


func _reset_dragged_pieces():
	var pieces = _pieces_to_drag.duplicate()
	var offset = Vector3.UP * (pieces.front() as Piece).get_height_scaled()
	for i in pieces.size():
		var piece = pieces[i] as Piece
		var target_pos = _selected_from_spot.global_position + (i * offset)
		piece.move(target_pos, General.MoveAnim.LINE)
	await (pieces.front() as Piece).movement_finished


func _update_dragged_pieces(delta : float):
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var plane = Plane(Vector3.UP, Vector3(0, board_surface_y, 0))
	var result = plane.intersects_ray(cam.project_ray_origin(mouse_pos), cam.project_ray_normal(mouse_pos))
	
	if result != null:
		for piece in _pieces_to_drag:
			var x = clamp(result.x, -1.5, 2.5)
			var z = clamp(result.z, -5, 5)
			
			var index = _pieces_to_drag.find(piece)
			var y = 1 + General.PIECE_OFFSET_Y * piece.scale.y * index
			var target_pos = Vector3(x,y,z)
			piece.global_position = lerp(piece.global_position, target_pos, 8 * delta)
