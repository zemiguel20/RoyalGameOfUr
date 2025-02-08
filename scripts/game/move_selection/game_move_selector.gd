class_name GameMoveSelector
extends Node
## Abstract class for move selectors. Contains some common functions.


@warning_ignore("unused_signal")
signal move_selected(move: GameMove)


@warning_ignore("unused_parameter")
func start_selection(moves: Array[GameMove]) -> void:
	push_warning("Using abstract method. Implement method in concrete class.")


func _highlight_move(move: GameMove) -> void:
	var base_color = Highlight.get_color(Highlight.Type.NEUTRAL)
	move.from.enable_highlight(base_color)
	for piece in move.pieces_in_from:
		piece.enable_highlight(base_color)
	
	var to_color = _get_to_spot_color(move)
	
	move.to.enable_highlight(to_color)
	for piece in move.pieces_in_to:
		piece.enable_highlight(to_color)
	
	var path_highlight = _create_path_highlighter(move)
	path_highlight.color_modulate = to_color


func _clear_move_highlight(move: GameMove) -> void:
	_delete_path_highlighter(move)
	
	move.from.disable_highlight()
	for piece in move.pieces_in_from:
		piece.disable_highlight()
	
	move.to.disable_highlight()
	for piece in move.pieces_in_to:
		piece.disable_highlight()


func _get_to_spot_color(move: GameMove) -> Color:
	if move.to_is_end_of_track:
		return Highlight.get_color(Highlight.Type.END)
	elif move.knocks_opponent_out:
		return Highlight.get_color(Highlight.Type.KO)
	elif move.to.is_rosette and (move.to_is_safe or move.stacks or move.gives_extra_turn):
		return Highlight.get_color(Highlight.Type.ROSETTE)
	else:
		return Highlight.get_color(Highlight.Type.NEUTRAL)


# Creates a path highlighter for the given move. If the move already has an associated
# path highlighter, returns that one instead.
func _create_path_highlighter(move: GameMove) -> ScrollingTexturePath3D:
	var path_highlighter_name: String = "%s%sHighlight" % [move.from.name, move.to.name]
	
	var path: ScrollingTexturePath3D
	if has_node(path_highlighter_name):
		path = get_node(path_highlighter_name)
		return path
	
	var path_highlight_prebab = preload("res://scenes/game/path_highlight.tscn")
	path = path_highlight_prebab.instantiate() as ScrollingTexturePath3D
	path.name = path_highlighter_name
	add_child(path)
	
	# Add all spots to the curve
	# Midpoints form an arch to fix clipping through board
	var curve = Curve3D.new()
	for i in move.full_path.size():
		var spot = move.full_path[i]
		curve.add_point(spot.global_position)
		
		if i < move.full_path.size() - 1:
			var next_spot = move.full_path[i + 1]
			var midpoint = spot.global_position.lerp(next_spot.global_position, 0.5)
			midpoint.y = maxf(spot.global_position.y, next_spot.global_position.y) + 0.002
			curve.add_point(midpoint)
	
	path.curve = curve
	
	return path


func _delete_path_highlighter(move: GameMove) -> void:
	var path_highlighter_name: String = "%s%sHighlight" % [move.from.name, move.to.name]
	
	if has_node(path_highlighter_name):
		var path = get_node(path_highlighter_name)
		path.queue_free()
		# NOTE: this makes sure that _create_path_highlighter cannot find this since
		# freeing node is defered.
		path.name = path.name + "DELETED"
