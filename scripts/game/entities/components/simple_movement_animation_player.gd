class_name SimpleMovementAnimationPlayer
extends Node
## Provides simple movement animations. It works in global coordinates.


## Emitted when it finished the movement animation.
signal movement_finished

## Animation target.
@export var root_target: Node3D

## If its currently playing the movement animation.
var is_moving: bool = false 


## Moves the object to the target point [param target_pos] in an arc trajectory.
## 
## [param target_pos]: target position in global coordinates.
##
## [param duration]: duration of the animation in seconds.
##
## [param arc_height]: Height offset in meters for the arc animation,
## relative to the highest point between the current and target positions.
##
func move_arc(target_pos: Vector3, duration: float, arc_height: float):
	# Instead of computing a curve for the object to follow, the animation is divided in 2 parts.
	# The horizontal translation (in the XZ plane) is done with a linear function.
	# The vertical translation (Y axis) is done with a cubic function.
	# If both are performed at the same time, over the same time length,
	# then the mapped 3D curve is an arc.
	#
	# NOTE: The shape of the arc depends on the function used for the vertical translation.
	# A quadratic or sine function will result in a sharper arc,
	# and an exponential function will result in a more rounded arc.
	# https://vitorgus.github.io/Godot-Tween-Interactive-Cheat-Sheet/
	
	# Tween X and Z linearly
	var tween_xz = create_tween()
	tween_xz.bind_node(self).set_parallel(true)
	tween_xz.tween_property(root_target, "global_position:x", target_pos.x, duration)
	tween_xz.tween_property(root_target, "global_position:z", target_pos.z, duration)
	
	# Compute highest point
	var current_pos = root_target.global_position
	var high_point = maxf(current_pos.y, target_pos.y) + arc_height
	# Tween Y cubicaly in 2 steps. Ease Out to highest point, and then Ease In to target point.
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(root_target, "global_position:y", high_point, duration * 0.5) \
	.set_ease(Tween.EASE_OUT)
	tween_y.tween_property(root_target, "global_position:y", target_pos.y, duration * 0.5) \
	.set_ease(Tween.EASE_IN)
	
	is_moving = true
	if tween_xz.is_running():
		await tween_xz.finished # Tweens run at same time, so only wait for one of them
	is_moving = false
	movement_finished.emit()


## Moves the object to the target point [param target_pos] in a line trajectory.
## Movement is faster at the start to "snap" the object.
## 
## [param target_pos]: target position in global coordinates.
##
## [param duration]: duration of the animation in seconds.
##
func move_line(target_pos: Vector3, duration: float):
	var tween = create_tween().bind_node(self)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(root_target, "global_position", target_pos, duration)
	
	is_moving = true
	if tween.is_running():
		await tween.finished
	is_moving = false
	movement_finished.emit()
