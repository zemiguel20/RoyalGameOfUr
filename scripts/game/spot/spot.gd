class_name Spot
extends Node3D
## Base class for board spots


signal pieces_knocked_out(pieces: Array[Piece])

@export var is_safe: bool = false
@export var give_extra_roll: bool = false
@export var _highlighter: MaterialHighlighter

var _pieces: Array[Piece] = []


func highlight() -> void:
	if _highlighter != null:
		_highlighter.highlight()


func dehighlight() -> void:
	if _highlighter != null:
		_highlighter.dehighlight()


func place_pieces(new_pieces: Array[Piece], anim: Piece.MOVE_ANIM):
	if not can_place(new_pieces):
		push_warning("Cannot move to this spot.")
		return
	
	await _place_animation(new_pieces, anim)
	
	var player = new_pieces.front().player
	if not is_occupied(player) and not _pieces.is_empty():
		var opponent_pieces = remove_pieces()
		pieces_knocked_out.emit(opponent_pieces)
		
	_pieces.append_array(new_pieces)


func can_place(pieces: Array[Piece]) -> bool:
	var player = (pieces.front() as Piece).player
	
	if is_occupied(player) and not is_safe:
		return false
	
	if is_occupied(player) and is_safe and not Settings.CAN_STACK_IN_SAFE_SPOT:
		return false
	
	if not is_occupied(player) and not _pieces.is_empty() and is_safe:
		return false
	
	return true


func is_occupied(player: int) -> bool:
	return not _pieces.is_empty() and player == _pieces.front().player


func remove_pieces() -> Array[Piece]:
	var pieces = _pieces.duplicate()
	_pieces.clear()
	return pieces


func get_pieces() -> Array[Piece]:
	return _pieces.duplicate()


func _place_animation(pieces: Array[Piece], anim: Piece.MOVE_ANIM):
	# Temporary reparent of stack to bottom piece so they all move together
	var base_piece = pieces.front() as Piece
	var other_pieces = pieces.slice(1, pieces.size()) as Array[Piece]
	for piece in other_pieces:
		piece.reparent(base_piece)
	
	var base_pos = global_position if _pieces.is_empty() else _pieces.back().global_position
	var target_pos = base_pos + (Vector3.UP * 0.3)
	await base_piece.move(target_pos, anim)
	
	for piece in other_pieces:
		piece.reparent(base_piece.get_parent())
