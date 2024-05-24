class_name Piece extends Node3D
## Physical piece in the game. Can be moved with a given animation. Also has highlight effects.


var highlight: MaterialHighlight
var move_anim: MoveAnimation
var model: MeshInstance3D


func _ready():
	highlight = get_node(get_meta("highlight")) as MaterialHighlight
	move_anim = get_node(get_meta("move")) as MoveAnimation
	model = get_node(get_meta("model")) as MeshInstance3D


## Model height, with global scale applied.
func get_height_scaled() -> float:
	var model_bounding_box = model.mesh.get_aabb() as AABB
	return model_bounding_box.size.y * model.global_basis.get_scale().y
