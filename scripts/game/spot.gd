class_name Spot
extends Node3D
## A spot in the board that can hold a piece or a stack of pieces.
## Contains game logic for placing pieces.
## Also has highlight effects.


signal pieces_knocked_out(pieces: Array[Piece])
signal mouse_entered
signal mouse_exited
signal selected

const PIECE_OFFSET_Y = 0.15

@export var is_safe: bool = false
@export var give_extra_roll: bool = false
@export var force_allow_stack: bool = false ## If true, always allows stacking, independent of settings

var _pieces: Array[Piece] = []
var _highlighter


func _ready():
	_highlighter = get_node("Highlighter")


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
		pieces_knocked_out.emit(knocked_out_pieces)
	
	var num_pieces = _pieces.size() # FOR ANIMATION
	
	_pieces.append_array(new_pieces)
	
	await _place_animation(new_pieces, anim, num_pieces)
	
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


func highlight_base():
	if _highlighter != null:
		_highlighter.highlight()


func highlight_pieces():
	for piece in _pieces:
		piece.highlight()


func dehighlight_base():
	if _highlighter != null:
		_highlighter.dehighlight()


func dehighlight_pieces():
	for piece in _pieces:
		piece.dehighlight()


func _place_animation(new_pieces: Array[Piece], anim: Piece.MoveAnim, curr_num_pieces: int):
	var offset = Vector3.UP * PIECE_OFFSET_Y * global_basis.get_scale()		## Take scale of the board into account!
	var base_pos = global_position + offset + (curr_num_pieces * offset)
	for i in new_pieces.size():
		var piece = new_pieces[i]
		var target_pos = base_pos + (i * offset)
		piece.move(target_pos, anim)
	
	await get_tree().create_timer(Piece.MOVE_DURATION).timeout


func _on_mouse_entered():
	mouse_entered.emit()


func _on_mouse_exited():
	mouse_exited.emit()


func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			selected.emit()
