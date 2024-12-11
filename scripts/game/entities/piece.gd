class_name Piece extends Node3D
## Entity that represents a physical piece that a player moves through the tiles of the board.
## It has a highlight component for highlight effects during move phase.
## Also it has a move animation component for animating the movement of the piece.
## Holds a reference to the spot where it is currently placed.


signal movement_finished

@export var player: General.Player

@onready var _mesh_highlighter: MeshHighlighter = $MeshHighlighter
@onready var _animator: SimpleMovementAnimationPlayer = $SimpleMovementAnimationPlayer
@onready var _mesh: MeshInstance3D = $Model/Piece
@onready var _sfx_place: AudioStreamPlayer3D = $SfxPlace


func _ready():
	_animator.movement_finished.connect(_sfx_place.play)
	_animator.movement_finished.connect(movement_finished.emit)


func enable_highlight(color: Color) -> void:
	_mesh_highlighter.set_active(true).set_material_color(color)


func disable_highlight() -> void:
	_mesh_highlighter.set_active(false)


func move_arc(target_pos: Vector3, duration: float, arc_height: float) -> void:
	_animator.move_arc(target_pos, duration, arc_height)


func move_line(target_pos: Vector3, duration: float) -> void:
	_animator.move_line(target_pos, duration)


## Model height, with global scale applied.
func get_height_scaled() -> float:
	var model_bounding_box = _mesh.mesh.get_aabb() as AABB
	return model_bounding_box.size.y * _mesh.global_basis.get_scale().y
