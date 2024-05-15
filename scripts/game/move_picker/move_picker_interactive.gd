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


func start(moves : Array[Move]):
	_moves = moves.duplicate()
	_change_state(State.FROM_SELECT)


#func _process(_delta):
	#if not _pieces_to_drag.is_empty():
		#_update_dragged_pieces()


func _input(event):
	if _state == State.TO_SELECT and event.is_action_pressed("game_spot_selection_cancel"):
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
				for piece in move.pieces_in_from:
					piece.set_highlight(true)
	
		State.TO_SELECT:
			# Connect signals for input interaction
			var filtered_moves = _filter_moves(_selected_from_spot)
			for move in filtered_moves:
				var spot = move.to
				if not spot.selected.is_connected(_on_to_selected.bind(spot)):
					spot.selected.connect(_on_to_selected.bind(spot))
			
			# Highlight moves
			for move in filtered_moves:
				move.from.set_highlight(true, Color.GREEN)
				move.to.set_highlight(true, Color.GREEN)
				for piece in move.pieces_in_from:
					piece.set_highlight(true, Color.GREEN)
				var path_highlighter = _create_path_highlighter(move)
				add_child(path_highlighter)
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
		move.from.set_highlight(false)
		move.to.set_highlight(false)
		for piece in move.pieces_in_from:
			piece.set_highlight(false)
		for piece in move.pieces_in_to:
			piece.set_highlight(false)
	for path_highlighter in get_children():
		path_highlighter.queue_free()


func _on_from_hovered(from : Spot):
	# Highlight moves including from
	for move in _filter_moves(from):
		move.from.set_highlight(true)
		move.to.set_highlight(true)
		var path_highlighter = _create_path_highlighter(move)
		add_child(path_highlighter)


func _on_from_dehovered(from : Spot):
	# Remove highlight moves including from
	for move in _filter_moves(from):
		move.from.set_highlight(false)
		move.to.set_highlight(false)
	for path_highlighter in get_children():
		path_highlighter.queue_free()


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
	
	await selected_move.execute(Piece.MoveAnim.ARC)
	move_executed.emit(selected_move)


func _create_path_highlighter(move : Move) -> ScrollingTexturePath3D:
	var move_path_highlight = preload("res://scenes/move_path_highlight.tscn")
	var path = move_path_highlight.instantiate()
	path.curve.clear_points()
	
	path.curve.add_point(move.from.global_position)
	
	# Midpoint to fix clipping through board
	var midpoint = move.from.global_position.lerp(move.to.global_position, 0.5)
	midpoint.y = maxf(move.from.global_position.y, move.to.global_position.y)
	path.curve.add_point(midpoint)
	
	path.curve.add_point(move.to.global_position)
	
	return path


func _start_drag():
	_pieces_to_drag = _filter_moves(_selected_from_spot).front().pieces_in_from
	# Temporarily reparents all pieces to base piece of stack for dragging
	var base_piece = _pieces_to_drag.front() as Piece
	for piece : Piece in _pieces_to_drag.slice(1):
		piece.reparent(base_piece)


func _stop_drag():
	# Restores original hierarchy
	var base_piece = _pieces_to_drag.front() as Piece
	for piece : Piece in _pieces_to_drag.slice(1):
		piece.reparent(base_piece.get_parent())
	
	_pieces_to_drag.clear()


func _update_dragged_pieces():
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var plane = Plane(Vector3.UP, Vector3(0, board_surface_y, 0))
	var result = plane.intersects_ray(cam.project_ray_origin(mouse_pos), cam.project_ray_normal(mouse_pos))
	
	if result != null:
		for piece in _pieces_to_drag:
			var x = clamp(result.x, -1.5, 2.5)
			var z = clamp(result.z, -5, 5)
			
			var index = _pieces_to_drag.find(piece)
			var y = General.PIECE_OFFSET_Y * piece.scale.y * index
			piece.target_pos = Vector3(x, piece.global_position.y, z)
