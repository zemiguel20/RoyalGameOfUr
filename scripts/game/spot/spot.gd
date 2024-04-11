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
func place_pieces(new_pieces: Array[Piece], anim: Piece.MOVE_ANIM) -> Array[Piece]:
	var knocked_out_pieces: Array[Piece] = []
	
	if not can_place(new_pieces):
		push_warning("Cannot move to this spot.")
		return knocked_out_pieces
	
	var player = new_pieces.front().player
	if not is_occupied(player) and not _pieces.is_empty():
		knocked_out_pieces = remove_pieces()
	
	await _place_animation(new_pieces, anim)
	
	_pieces.append_array(new_pieces)
	
	return knocked_out_pieces


func can_place(pieces: Array[Piece]) -> bool:
	var player = (pieces.front() as Piece).player
	
	# NOTE: Check if any rule is violated, otherwise return true
	
	if is_occupied(player) and not force_allow_stack and not is_safe:
		return false
	
	if is_occupied(player) and not force_allow_stack and is_safe and not Settings.CAN_STACK_IN_SAFE_SPOT:
		return false
	
	if not is_occupied(player) and not _pieces.is_empty() and is_safe:
		return false
	
	return true


func is_occupied(player: General.PLAYER) -> bool:
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
	
	# TODO: take dimensions into account
	var base_pos = global_position if _pieces.is_empty() else _pieces.back().global_position
	var target_pos = base_pos + (Vector3.UP * 0.3)
	await base_piece.move(target_pos, anim)
	
	for piece in other_pieces:
		piece.reparent(base_piece.get_parent())
