class_name MoveHighlighterComponent extends Node


@export var color_selectable: Color = Color.WHITE
@export var color_selected: Color = Color.DEEP_SKY_BLUE
@export var color_safe: Color = Color.AQUAMARINE
@export var color_end: Color = Color.YELLOW
@export var color_knock_out: Color = Color.ORANGE
@export var path_highlighter_scene: PackedScene

# Move -> Path Highlighter
var move_path_highlighter_dict: Dictionary = {}


## Highlight that hints the pieces can be selected to be moved.
func highlight_selectable_pieces(move: Move) -> void:
	clear_highlight(move)
	
	for piece in move.pieces_in_from:
		piece.set_highlight(true, color_selectable)


## Highlights info about the move. For example, useful for previewing outcome of move when hovering
## over the pieces.
func highlight_move_preview(move: Move) -> void:
	move.from.set_highlight(true, color_selectable)
	for piece in move.pieces_in_from:
		piece.set_highlight(true, color_selectable)
	
	var to_color: Color
	if move.to.is_safe:
		to_color = color_safe
	elif move.knocks_opo:
		to_color = color_knock_out
	elif move.moves_to_end:
		to_color = color_end
	else:
		to_color = color_selectable
	
	move.to.set_highlight(true, to_color)
	for piece in move.pieces_in_to:
		piece.set_highlight(true, to_color)
	
	_create_path_highlighter(move)


## Highlight that hints the pieces are selected, and info about the move.
## Can be used while the move is being confirmed (for example, during a drag and drop)
func highlight_pieces_selected(move: Move) -> void:
	# Override preview highlighting with appropriate selection color
	highlight_move_preview(move)
	move.from.set_highlight(true, color_selected)
	for piece in move.pieces_in_from:
		piece.set_highlight(true, color_selected)


func clear_highlight(move: Move) -> void:
	move.from.set_highlight(false)
	move.to.set_highlight(false)
	for piece in move.pieces_in_from:
		piece.set_highlight(false)
	for piece in move.pieces_in_to:
		piece.set_highlight(false)
	
	if move_path_highlighter_dict.has(move):
		var path = move_path_highlighter_dict[move]
		path.queue_free()
		move_path_highlighter_dict.erase(move)


# Creates a path highlighter for the given move. If the move already has an associated
# path highlighter, returns that one instead.
func _create_path_highlighter(move: Move) -> ScrollingTexturePath3D:
	if move_path_highlighter_dict.has(move):
		return move_path_highlighter_dict[move]
	
	var path = path_highlighter_scene.instantiate()
	
	path.curve.clear_points()
	
	path.curve.add_point(move.from.global_position)
	
	# Midpoint to fix clipping through board
	var midpoint = move.from.global_position.lerp(move.to.global_position, 0.5)
	midpoint.y = maxf(move.from.global_position.y, move.to.global_position.y)
	path.curve.add_point(midpoint)
	
	path.curve.add_point(move.to.global_position)
	
	# Save path
	move_path_highlighter_dict[move] = path
	add_child(path)
	
	return path
