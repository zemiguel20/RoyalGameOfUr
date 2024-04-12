class_name Spot
extends Node3D
## A spot in the board that can hold a piece or a stack of pieces.
## Contains game logic for placing pieces.
## Also has highlight effects.


@export var is_safe: bool = false
@export var give_extra_roll: bool = false
@export var force_allow_stack: bool = false ## If true, always allows stacking, independent of settings

var _pieces: Array[Piece] = []
var _highlighter


func _ready():
	_highlighter = get_node("Highlighter")


func highlight():
	if _highlighter == null:
		push_warning("No highlighter found")
		return
	_highlighter.highlight()


func dehighlight():
	if _highlighter == null:
		push_warning("No highlighter found")
		return
	_highlighter.dehighlight()


## Places the new pieces in the spot, with the given animation.
## Returns a list of knocked out pieces. If no pieces where knocked out, this list is empty.
func place_pieces(new_pieces: Array[Piece], anim: Piece.MoveAnim) -> Array[Piece]:
	var knocked_out_pieces: Array[Piece] = []
	
	if not can_place(new_pieces):
		push_error("Cannot move to this spot.")
		return knocked_out_pieces
	
	var player = new_pieces.front().player
	if not is_occupied(player) and not is_free():
		knocked_out_pieces = remove_pieces()
	
	# TODO: UNTIE ANIMATION FROM CURRENT STACK TO REMOVE SYNC PROBLEMS
	await _place_animation(new_pieces, anim)
	
	_pieces.append_array(new_pieces)
	
	return knocked_out_pieces


func place_piece(new_piece: Piece, anim: Piece.MoveAnim) -> Array[Piece]:
	return await place_pieces([new_piece], anim)


func can_place(pieces: Array[Piece]) -> bool:
	var player = (pieces.front() as Piece).player
	
	# NOTE: Check if any rule is violated, otherwise return true
	
	if is_occupied(player) and not force_allow_stack and not is_safe:
		return false
	
	if is_occupied(player) and not force_allow_stack and is_safe and not Settings.can_stack_in_safe_spot:
		return false
	
	if not is_occupied(player) and not is_free() and is_safe:
		return false
	
	return true


func is_occupied(player: General.Player) -> bool:
	return not is_free() and player == _pieces.front().player


func is_free() -> bool:
	return _pieces.is_empty()


func get_pieces() -> Array[Piece]:
	return _pieces.duplicate()


func remove_pieces() -> Array[Piece]:
	var pieces = _pieces.duplicate()
	_pieces.clear()
	return pieces


func _place_animation(pieces: Array[Piece], anim: Piece.MoveAnim):
	# Temporary reparent of stack to bottom piece so they all move together
	var base_piece = pieces.front() as Piece
	var other_pieces = pieces.slice(1, pieces.size()) as Array[Piece]
	for piece in other_pieces:
		piece.reparent(base_piece)
	
	# TODO: take dimensions into account
	var base_pos = global_position if is_free() else _pieces.back().global_position
	var target_pos = base_pos + (Vector3.UP * 0.3)
	await base_piece.move(target_pos, anim)
	
	for piece in other_pieces:
		piece.reparent(base_piece.get_parent())
