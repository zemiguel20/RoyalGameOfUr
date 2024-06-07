class_name MoveAnimation extends Node
## Component that provides movement animations. It works in global coordinates.


## Emitted when the movement animation has finished.
signal movement_finished

## Object to animate.
@export var root_parent: Node3D

## Height offset (in meters) for the arc animation, 
## relative to the highest point between 'to' and 'from'.
@export_range(0.0, 100.0, 0.001, "or_greater", "suffix:m")
var arc_height: float = 1.0

## Movement duration in seconds.
@export_range(0.0, 5.0, 0.1, "or_greater", "suffix:s")
var duration: float = 1.0

var moving: bool = false ## If its currently playing the movement animation.


## Moves the object to the target point [param target_pos], in global coordinates.
## An animation [param anim] can be specified.
func play(target_pos: Vector3, anim := General.MoveAnim.NONE) -> void:
	match anim:
		General.MoveAnim.ARC:
			_play_arc(target_pos)
		General.MoveAnim.LINE:
			_play_line(target_pos)
		_:
			root_parent.global_position = target_pos
			(func(): movement_finished.emit()).call_deferred()


func _play_arc(target_pos: Vector3):
	# Linear translation of X and Z
	var tween_xz = create_tween()
	tween_xz.bind_node(self).set_parallel(true)
	tween_xz.tween_property(root_parent, "global_position:x", target_pos.x, duration)
	tween_xz.tween_property(root_parent, "global_position:z", target_pos.z, duration)
	
	# Arc translation of Y
	var current_pos = root_parent.global_position
	var scale = root_parent.global_basis.get_scale().y
	var high_point = maxf(current_pos.y, target_pos.y) + arc_height * scale
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(root_parent, "global_position:y", high_point, duration * 0.5) \
	.set_ease(Tween.EASE_OUT)
	tween_y.tween_property(root_parent, "global_position:y", target_pos.y, duration * 0.5) \
	.set_ease(Tween.EASE_IN)
	
	moving = true
	await tween_xz.finished # Tweens run at same time, so only wait for one of them
	moving = false
	movement_finished.emit()


func _play_line(target_pos: Vector3):
	var tween = create_tween().bind_node(self)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(root_parent, "global_position", target_pos, duration)
	
	moving = true
	await tween.finished
	moving = false
	movement_finished.emit()
