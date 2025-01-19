class_name Spot
extends Node3D
## Entity that represents a spot where the player can place pieces.


signal mouse_entered
signal mouse_exited
signal clicked

@export var is_rosette: bool

var pieces: Array[Piece] = []

@onready var _outline_highlighter: MeshHighlighter = $OutlineFrameMesh/MeshHighlighter
@onready var _overlay_highlighter: MeshHighlighter = $OverlayFrameMesh/MeshHighlighter
@onready var _input_reader: SelectionInputReader = $SelectionInputReader


func _ready() -> void:
	_input_reader.mouse_entered.connect(mouse_entered.emit)
	_input_reader.mouse_exited.connect(mouse_exited.emit)
	_input_reader.clicked.connect(clicked.emit)


# NOTE: Places without animation. Pieces should be animated externally before calling this.
func place(new_piece: Piece) -> void:
	new_piece.reparent(self)
	new_piece.global_position = get_placing_position_global()
	pieces.append(new_piece)


func place_stack(stack: Array[Piece]) -> void:
	for piece in stack:
		place(piece)


func get_placing_position_global() -> Vector3:
	var placing_pos = global_position
	if not pieces.is_empty():
		placing_pos.y += pieces.size() * (pieces.front() as Piece).get_model_height()
	return placing_pos


func remove_pieces() -> Array[Piece]:
	var temp = pieces.duplicate()
	for piece in pieces:
		piece.reparent(get_parent())
	pieces.clear()
	return temp


func is_occupied_by_player(player: int) -> bool:
	var filter = func(piece: Piece): return piece.player == player
	return not pieces.filter(filter).is_empty()


func is_free() -> bool:
	return pieces.is_empty()


func enable_highlight(color: Color) -> void:
	_outline_highlighter.set_active(true).set_material_color(color)
	_overlay_highlighter.set_active(true).set_material_color(color)


func disable_highlight() -> void:
	_outline_highlighter.set_active(false)
	_overlay_highlighter.set_active(false)


func set_input_reading(active: bool) -> void:
	_input_reader.set_input_reading(active)
