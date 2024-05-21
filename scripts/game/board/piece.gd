class_name Piece extends Node3D
## Physical piece in the game. Can be moved with a given animation. Also has highlight effects.


signal movement_finished

@onready var _highlighter := $Highlighter as MaterialHighlighterComponent
@onready var _model = $Model as MeshInstance3D
@onready var _movable = $Movable as MovableComponent


## Updates the highlight state. [param active] sets the active state of the effect, and
## [param color] sets the color of the effect.
func set_highlight(active: bool, color := Color.WHITE) -> void:
	if not _highlighter:
		return
	
	_highlighter.highlight_color = color
	_highlighter.active = active


## Moves the piece to the target point [param dest], in global coordinates.
## An animation [param anim] can be specified.
func move(dest: Vector3, anim := General.MoveAnim.NONE) -> void:
	_movable.move(dest, anim)


## Model height, with global scale applied.
func get_height_scaled() -> float:
	var model_bounding_box = _model.mesh.get_aabb() as AABB
	return model_bounding_box.size.y * _model.global_basis.get_scale().y


func _on_movable_finished():
	movement_finished.emit()
