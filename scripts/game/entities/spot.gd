class_name Spot
extends Node3D
## Entity that represents a spot where the player can place pieces.


const STACKING_OFFSET: float = 0.03

@export var is_rosette: bool

var pieces: Array[Piece] = []


# Places without animation
func place(new_piece: Piece) -> void:
	add_child(new_piece)
	
	var target_position = global_position
	target_position.y += pieces.size() * STACKING_OFFSET
	new_piece.global_position = target_position
	
	pieces.append(new_piece)


func is_occupied_by_player(player: int) -> bool:
	var filter = func(piece: Piece): return piece.player == player
	return not pieces.filter(filter).is_empty()


func is_free() -> bool:
	return pieces.is_empty()

#========================================
# OLD CODE
#========================================



signal pieces_moved


var moving_pieces: bool = false

@onready var outline_highlighter: MeshHighlighter = $OutlineFrameMesh/MeshHighlighter
@onready var overlay_highlighter: MeshHighlighter = $OverlayFrameMesh/MeshHighlighter
@onready var input_reader: SelectionInputReader = $SelectionInputReader


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







func _move_pieces(spots: Array[Spot], anim: General.MoveAnim) -> void:
	var pieces_copy: Array[Piece] = pieces.duplicate()
	pieces.clear()
	
	for i in pieces_copy.size():
		var piece = pieces_copy[i]
		# Assume there is only one spot to place, or enough number of spots
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
