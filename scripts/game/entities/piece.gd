class_name Piece extends Node3D
## Entity that represents a physical piece that a player moves through the tiles of the board.
## It has a highlight component for highlight effects during move phase.
## Also it has a move animation component for animating the movement of the piece.
## Holds a reference to the spot where it is currently placed.


var highlight: MaterialHighlight
var move_anim: MoveAnimation
var model: MeshInstance3D

var current_spot: Spot


func _ready():
	highlight = get_node(get_meta("highlight")) as MaterialHighlight
	move_anim = get_node(get_meta("move")) as MoveAnimation
	model = get_node(get_meta("model")) as MeshInstance3D


## Model height, with global scale applied.
func get_height_scaled() -> float:
	var model_bounding_box = model.mesh.get_aabb() as AABB
	return model_bounding_box.size.y * model.global_basis.get_scale().y
