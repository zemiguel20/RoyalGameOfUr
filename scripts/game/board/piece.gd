class_name Piece
extends Node3D
## Physical piece in the game. Can be moved with a given animation. Also has highlight effects.


## Types of animation for the movement. Animation duration defined in [constant MOVE_DURATION].
enum MoveAnim {
	ARC, ## Moves from point A to B in a arc. Uses [constant MOVE_ARC_HEIGHT].
	LINE, ## Moves linearly from point A to B.
	NONE, ## No animation. Movement is instantaneous.
}

## Height offset (in meters) for the ARC animation, 
## relative to the highest point between 'to' and 'from'.
const MOVE_ARC_HEIGHT : float = 1.0
## Movement duration in seconds.
const MOVE_DURATION : float = 0.4

@onready var _highlighter := $Highlighter as MaterialHighlighterComponent


## Updates the highlight state. [param active] sets the active state of the effect, and
## [param color] sets the color of the effect.
func set_highlight(active : bool, color := Color.WHITE) -> void:
	if not _highlighter:
		return
	
	_highlighter.highlight_color = color
	_highlighter.active = active


## Moves the piece to the target point [param dest], in global coordinates.
## An animation [param anim] can be specified.
func move(dest : Vector3, anim : MoveAnim = MoveAnim.NONE) -> void:
	match anim:
		MoveAnim.ARC:
			await _move_arc(dest)
		MoveAnim.LINE:
			await _move_line(dest)
		_:
			global_position = dest


func _move_arc(target_pos: Vector3):
	# Linear translation of X and Z
	var tween_xz = create_tween()
	tween_xz.bind_node(self).set_parallel(true)
	tween_xz.tween_property(self, "global_position:x", target_pos.x, MOVE_DURATION)
	tween_xz.tween_property(self, "global_position:z", target_pos.z, MOVE_DURATION)
	
	# Arc translation of Y
	var high_point = maxf(global_position.y, target_pos.y) + MOVE_ARC_HEIGHT * global_basis.get_scale().y
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(self, "global_position:y", high_point, MOVE_DURATION * 0.5).set_ease(Tween.EASE_OUT)
	tween_y.tween_property(self, "global_position:y", target_pos.y, MOVE_DURATION * 0.5).set_ease(Tween.EASE_IN)
	
	# Tweens run at same time, so only wait for one of them
	await tween_xz.finished


func _move_line(target_pos: Vector3):
	var tween = create_tween().bind_node(self)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, MOVE_DURATION)
	await tween.finished
