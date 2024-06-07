class_name Spot extends Node3D
## Entity that represents a spot where the player can place pieces.
## Holds a list of placed pieces, and can move pieces to another spot.
## It also has configurable game properties like protecting pieces from knockout.
## Has an input reading component for player move selection.
## Has a highlight component for highlight effects during move phase.


signal pieces_moved

## If true, the pieces in this spot cannot get knocked out.
@export var safe: bool = false

## If true, if the player moves to this spot they should get an extra turn.
@export var give_extra_turn: bool = false

var highlight: MaterialHighlight
var input: SelectionInputReader
var pieces: Array[Piece] = []
var moving_pieces: bool = false

func _ready() -> void:
	if has_meta("highlight"):
		highlight = get_node(get_meta("highlight")) as MaterialHighlight
	if has_meta("input"):
		input = get_node(get_meta("input")) as SelectionInputReader


## Move the pieces in this spot to the target [param spot].
## An optional animation can be given for transfering the stack.
func move_pieces_to_spot(spot: Spot, anim := General.MoveAnim.NONE) -> void:
	if not spot or spot == self:
		return
	_move_pieces([spot], anim)


## Move the pieces in this spot to the target [param spots], split across them.
## The number of target spots must be the same as the number of pieces.
## An optional animation can be given for transfering the stack.
func move_pieces_split_to_spots(spots: Array[Spot], anim := General.MoveAnim.NONE) -> void:
	if not spots or spots.is_empty() or spots.has(self) or spots.size() < pieces.size():
		return
	_move_pieces(spots, anim)


## Get the topmost position of the current piece stack. Used to animate placing a new piece.
func get_placing_position_global() -> Vector3:
	var stack_height: float = 0.0
	for piece in pieces:
		stack_height += piece.get_height_scaled()
	
	var x: float = global_position.x
	var z: float = global_position.z
	var y: float = global_position.y + stack_height
	
	return Vector3(x, y, z)


func is_free() -> bool:
	return pieces.is_empty()


## Returns whether this spot contains at least a piece from the [param player].
func is_occupied_by_player(player: int) -> bool:
	var filter = func(piece: Piece): return piece.player_owner == player
	return not pieces.filter(filter).is_empty()


func _move_pieces(spots: Array[Spot], anim: General.MoveAnim) -> void:
	var pieces_copy: Array[Piece] = pieces.duplicate()
	pieces.clear()
	
	for i in pieces_copy.size():
		var piece = pieces_copy[i]
		# Assume there is only one spot to place, or an equal number of spots and pieces
		var spot = spots[i] if spots.size() > 1 else spots[0]
		
		# Update data and start animation
		var stack_pos = spot.get_placing_position_global()
		spot.pieces.append(piece)
		piece.current_spot = spot
		#piece.reparent(piece.current_spot)
		piece.move_anim.play(stack_pos, anim)
	
	# Wait for movement animation to finish
	for piece in pieces_copy:
		if piece.move_anim.moving:
			await piece.move_anim.movement_finished
	
	pieces_moved.emit()
