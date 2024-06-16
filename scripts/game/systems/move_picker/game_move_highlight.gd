class_name GameMoveHighlight extends Node


@export var color_neutral := Color.WHITE
@export var color_rosette := Color.GREEN_YELLOW
@export var color_end := Color.GOLD
@export var color_knock_out := Color.ORANGE
@export var color_invalid := Color.CRIMSON
@export var color_invalid_pieces := Color.YELLOW

@export var path_highlight_prefab: PackedScene

# Move -> Path Highlighter
var move_path_highlighter_dict: Dictionary = {}


## Highlights info about the move.
func highlight(move: GameMove, base_color := color_neutral) -> void:
	# NOTE: Valid moves and invalid get a different highlighting
	
	# Highlight spot FROM
	move.from.highlight.active = true
	move.from.highlight.color = base_color if move.valid else color_invalid
	
	# Highlight pieces FROM
	if move.valid:
		for piece in move.pieces_in_from:
			piece.highlight.set_active(true).set_color(base_color)
	
	# Highlight spot TO
	move.to.highlight.active = true
	if not move.valid:
		move.to.highlight.color = color_invalid
	elif move.is_to_end_of_track:
		move.to.highlight.color = color_end
	elif move.is_to_occupied_by_opponent:
		move.to.highlight.color = color_knock_out
	elif move.to.is_in_group("rosettes"):
		move.to.highlight.color = color_rosette
	else:
		move.to.highlight.color = base_color
	
	# Highlight pieces TO
	for piece in move.pieces_in_to:
		piece.highlight.active = true
		if not move.valid:
			piece.highlight.color = color_invalid_pieces
		elif move.is_to_occupied_by_opponent:
			piece.highlight.color = color_knock_out
		elif move.is_to_end_of_track:
			piece.highlight.color = color_end
		elif move.to.is_in_group("rosettes"):
			piece.highlight.color = color_rosette 
		else:
			piece.highlight.color = base_color
	
	# Highlight PATH
	var path = get_path_highlighter(move)
	var path_color
	if not move.valid:
		path.color_modulate = color_invalid
	elif move.is_to_end_of_track:
		path.color_modulate = color_end
	else:
		path.color_modulate = base_color


func clear_highlight(move: GameMove) -> void:
	if not move.from or not move.to:
		return
	
	move.from.highlight.set_active(false)
	move.to.highlight.set_active(false)
	for piece in move.pieces_in_from:
		piece.highlight.set_active(false)
	for piece in move.pieces_in_to:
		piece.highlight.set_active(false)
	
	if move_path_highlighter_dict.has(move):
		var path = move_path_highlighter_dict[move]
		path.queue_free()
		move_path_highlighter_dict.erase(move)


# Creates a path highlighter for the given move. If the move already has an associated
# path highlighter, returns that one instead.
func get_path_highlighter(move: GameMove) -> ScrollingTexturePath3D:
	if move_path_highlighter_dict.has(move):
		return move_path_highlighter_dict[move]
	
	var path = path_highlight_prefab.instantiate() as ScrollingTexturePath3D
	
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
	move_path_highlighter_dict[move] = path
	add_child(path)
	
	return path
