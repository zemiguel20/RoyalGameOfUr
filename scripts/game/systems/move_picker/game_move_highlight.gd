class_name GameMoveHighlight extends Node


@export var color_selectable := Color.WHITE
@export var color_selected := Color.DEEP_SKY_BLUE
@export var color_safe := Color.AQUAMARINE
@export var color_end := Color.YELLOW
@export var color_knock_out := Color.ORANGE
@export var color_invalid := Color.RED
@export var color_friend := Color.GREEN
@export var color_opponent := Color.RED

@export var path_highlight_prefab: PackedScene

# Move -> Path Highlighter
var move_path_highlighter_dict: Dictionary = {}


## Highlight that hints the pieces can be selected to be moved.
func highlight_selectable(move: GameMove) -> void:
	clear_highlight(move)
	
	# Highlight pieces only
	for piece in move.pieces_in_from:
		piece.highlight.set_active(true).set_color(color_selectable)


## Highlights info about the move. For example, useful for previewing outcome of move when hovering
## over the pieces.
func highlight_hovered(move: GameMove) -> void:
	# NOTE: Valid moves and invalid get a different highlighting
	
	# Highlight spot FROM
	move.from.highlight.active = true
	move.from.highlight.color = color_selectable if move.valid else color_invalid
	
	# Highlight pieces FROM
	if move.valid:
		for piece in move.pieces_in_from:
			piece.highlight.set_active(true).set_color(color_selectable)
	
	# Highlight spot TO
	var to_color: Color
	if not move.valid:
		to_color = color_invalid
	elif move.moves_to_end:
		to_color = color_end
	elif move.knocks_opo:
		to_color = color_knock_out
	elif move.to.safe:
		to_color = color_safe
	else:
		to_color = color_selectable
	
	move.to.highlight.set_active(true).set_color(to_color)
	
	# Highlight pieces TO
	for piece in move.pieces_in_to:
		piece.highlight.active = true
		piece.highlight.color = color_opponent if move.knocks_opo else color_friend
	
	# Highlight PATH
	_create_path_highlighter(move)


## Highlight that hints the pieces are selected, and info about the move.
## Can be used while the move is being confirmed (for example, during a drag and drop)
func highlight_selected(move: GameMove) -> void:
	# Override hovered highlighting with appropriate selection color
	highlight_hovered(move)
	move.from.highlight.set_active(true).set_color(color_selected)
	for piece in move.pieces_in_from:
		piece.highlight.set_active(true).set_color(color_selected)


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


# Creates a path highlighter for the given move. If the move already has an associated
# path highlighter, returns that one instead.
func _create_path_highlighter(move: GameMove) -> ScrollingTexturePath3D:
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
	
	# Set different color if invalid
	if not move.valid:
		path.color_modulate = color_invalid
	
	# Save path
	move_path_highlighter_dict[move] = path
	add_child(path)
	
	return path
