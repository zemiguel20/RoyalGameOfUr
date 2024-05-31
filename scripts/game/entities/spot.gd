class_name Spot extends Node3D
## Entity that represents a spot where the player can place pieces.
## Holds a list of placed pieces, and can move pieces to another spot.
## It also has configurable game properties like protecting pieces from knockout.
## Has an input reading component for player move selection.
## Has a highlight component for highlight effects during move phase.


## If true, the pieces in this spot cannot get knocked out.
@export var safe: bool = false

## If true, if the player moves to this spot they should get an extra turn.
@export var give_extra_turn: bool = false

var highlight: MaterialHighlight
var input: SelectionInputReader

var pieces: Array[Piece] = []


func _ready():
	highlight = get_node(get_meta("highlight")) as MaterialHighlight
	input = get_node(get_meta("input")) as SelectionInputReader


## Move the pieces in this spot to the target [param spot].
## An optional animation can be given for transfering the stack.
func move_pieces_to_spot(spot: Spot, anim := General.MoveAnim.NONE):
	if not spot or spot == self:
		return
	
	for piece in pieces:
		var stack_pos = spot.get_placing_position_global()
		piece.move_anim.play(stack_pos, anim)
		spot.pieces.append(piece)
		piece.current_spot = spot
	
	pieces.clear()


## Get the topmost position of the current piece stack. Used to animate placing a new piece.
func get_placing_position_global() -> Vector3:
	var stack_height: float = 0.0
	for piece in pieces:
		stack_height += piece.get_height_scaled()
	
	var x: float = global_position.x
	var z: float = global_position.z
	var y: float = stack_height
	
	return Vector3(x, y, z)


func is_free() -> bool:
	return pieces.is_empty()


func is_occupied_by_player(player: int) -> bool:
	var filter = func(piece: Piece): return piece.player_owner == player
	return not pieces.filter(filter).is_empty()
