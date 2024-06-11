class_name GameMoveHighlight extends Node


@export var color_neutral := Color.WHITE
@export var color_rosette := Color.AQUAMARINE
@export var color_end := Color.YELLOW
@export var color_knock_out := Color.ORANGE

@export var path_highlight_prefab: PackedScene

# Move -> Path Highlighter
var move_path_highlighter_dict: Dictionary = {}


## Highlights info about the move.
func highlight(move: GameMove, base_color := color_neutral) -> void:
	# NOTE: Valid moves and invalid get a different highlighting
	
	# Highlight spot FROM
	move.from.highlight.active = true
	move.from.highlight.color = base_color if move.valid else General.color_negative
	
	# Highlight pieces FROM
	if move.valid:
		for piece in move.pieces_in_from:
			piece.highlight.set_active(true).set_color(base_color)
	
	# Highlight spot TO
	move.to.highlight.active = true
	move.to.highlight.color = get_to_spot_color(move)
	
	# Highlight pieces TO
	for piece in move.pieces_in_to:
		piece.highlight.active = true
		piece.highlight.color = color_knock_out if move.knocks_opo else color_rosette
	
	# Highlight PATH
	var path = get_path_highlighter(move)
	path.color_modulate = base_color if move.valid else General.color_negative


func clear_highlight(move: GameMove) -> void:
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


func get_to_spot_color(move: GameMove) -> Color:
	if not move.valid:
		return General.color_negative
	elif move.is_to_end_of_track:
		return color_end
	elif move.knocks_opo:
		return color_knock_out
	elif move.to.is_in_group("rosettes"):
		return color_rosette
	else:
		return color_neutral


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
