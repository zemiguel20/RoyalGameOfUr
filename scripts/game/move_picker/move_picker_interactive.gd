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

# HACK
var _allow_dragging = false

func start(moves : Array[Move]):
	_moves = moves.duplicate()
	_change_state(State.FROM_SELECT)


func _process(delta):
	if not _pieces_to_drag.is_empty():
		_update_dragged_pieces(delta)


func _input(event):
	if event is InputEventKey and event.keycode == KEY_1:
		_allow_dragging = true
	if event is InputEventKey and event.keycode == KEY_2:
		_allow_dragging = false
	
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
		move.from.set_highlight(false)
		move.to.set_highlight(false)
		for piece in move.pieces_in_from:
			piece.set_highlight(false)
		for piece in move.pieces_in_to:
			piece.set_highlight(false)
	for path_highlighter in get_children():
		path_highlighter.queue_free()
	
	# Stops dragging pieces
	_pieces_to_drag.clear()


func _on_from_hovered(from : Spot):
	# Highlight moves including from
	for move in _filter_moves(from):
		move.from.set_highlight(true)
		move.to.set_highlight(true)
		var path_highlighter = _create_path_highlighter(move)
		add_child(path_highlighter)
		_check_for_tutorial_signals(move)


func _on_from_dehovered(from : Spot):
	# Remove highlight moves including from
	for move in _filter_moves(from):
		move.from.set_highlight(false)
		move.to.set_highlight(false)
	for path_highlighter in get_children():
		path_highlighter.queue_free()


func _on_from_selected(spot: Spot):
	if spot.force_allow_stack:
		on_play_tutorial_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_FINISH)
	
	_selected_from_spot = spot
	
	if not Settings.can_move_backwards and not _allow_dragging:
		_finalize_selection()
	else:
		_change_state(State.TO_SELECT)


func _on_to_selected(spot: Spot):	
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
	
	if selected_move.knocks_opo and has_emitted_tutorial_capture_signal:
		on_play_dialogue.emit(DialogueSystem.Category.GAME_OPPONENT_GETS_CAPTURED)
	
	await selected_move.execute(Piece.MoveAnim.ARC)
	move_executed.emit(selected_move)


func _check_for_tutorial_signals(move: Move):
	# TODO: Only run this method when playing with default rules
	on_play_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_EXPLANATION)
	
	if move.knocks_opo:
		on_play_tutorial_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_OPPONENT_GETS_CAPTURED)
		has_emitted_tutorial_capture_signal = true
	
	if move.to.is_safe:
		if move.is_to_central_safe:
			on_play_tutorial_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_CENTRAL_ROSETTE)
		else:
			on_play_tutorial_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_ROSETTE)
	
	if move.to.force_allow_stack:
		on_play_tutorial_dialogue.emit(DialogueSystem.Category.GAME_TUTORIAL_FINISH)


func _create_path_highlighter(move : Move) -> ScrollingTexturePath3D:
	var move_path_highlight = preload("res://scenes/move_path_highlight.tscn")
	var path = move_path_highlight.instantiate()
	
	var scale = move.from.global_basis.get_scale()
	path.sprite_scale = path.sprite_scale * scale
	path.density = path.density / scale.length()
	path.velocity = path.velocity * scale.length()
	
	path.curve.clear_points()
	
	path.curve.add_point(move.from.global_position)
	
	# Midpoint to fix clipping through board
	var midpoint = move.from.global_position.lerp(move.to.global_position, 0.5)
	midpoint.y = maxf(move.from.global_position.y, move.to.global_position.y)
	path.curve.add_point(midpoint)
	
	path.curve.add_point(move.to.global_position)
	
	return path


func _reset_dragged_pieces():
	# TODO: turn into function in piece - calculate stack offset
	# TODO: ajdust origin or pieces to remove need of offset/2
	var pieces = _pieces_to_drag.duplicate()
	var piece_scale = pieces.front().scale.y
	var offset = Vector3.UP * General.PIECE_OFFSET_Y * piece_scale
	var base_pos = _selected_from_spot.global_position + offset/2
	for i in pieces.size():
		var piece = pieces[i] as Piece
		var target_pos = base_pos + (i * offset)
		piece.move(target_pos, Piece.MoveAnim.LINE)


func _update_dragged_pieces(delta : float):
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var plane = Plane(Vector3.UP, Vector3(0, board_surface_y, 0))
	var result = plane.intersects_ray(cam.project_ray_origin(mouse_pos), cam.project_ray_normal(mouse_pos))
	
	if result != null:
		for piece in _pieces_to_drag:
			## HACK
			var x = clamp(result.x, piece.global_position.x - 1.5 * 0.05, piece.global_position.x + 2.5 * 0.05)
			var z = clamp(result.z, piece.global_position.z -5 * 0.05, piece.global_position.z + 5 * 0.05)
			
			## HACK Get the scaling right			
			var index = _pieces_to_drag.find(piece)
			var y = board_surface_y + 1 * piece.global_basis.get_scale().y + General.PIECE_OFFSET_Y * piece.global_basis.get_scale().y * index
			var target_pos = Vector3(x,y,z)
			piece.global_position = lerp(piece.global_position, target_pos, 8 * delta)
