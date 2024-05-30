## Uses an array of points to move along.
class_name MoveAlongPathTask
extends BTNode

var _owner: Node3D
var _path_follow: PathFollow3D
var _move_speed: float
var _rotation_speed: float

var _progression_speed
var _current_progress
var _target_rotation


func _init(path_follow: PathFollow3D):
	_path_follow = path_follow


func on_start():
	_owner = _blackboard.read("Base")
	_move_speed = _blackboard.read("Move Speed")
	_rotation_speed = _blackboard.read("Rotation Speed")
	
	# Decide progression speed based on length of path.
	_current_progress = 0
	_path_follow.progress = 0.001
	_owner.global_rotation.y = _path_follow.global_rotation.y

	
func on_process(delta) -> Status:
	# Update Position
	var prev_y_pos = _owner.global_position.y
	_owner.global_position = _path_follow.global_position
	_owner.global_position.y = prev_y_pos
	
	# Update Rotation: Smoothly follow the rotation of the followpath, but don't copy it.
	_target_rotation = _path_follow.global_rotation
	var difference = _owner.global_rotation.distance_to(_target_rotation)
	var speed = _rotation_speed * delta
	if difference > speed:
		_owner.global_rotation = _owner.global_rotation.lerp(_target_rotation, speed/difference)
	else:
		_owner.global_rotation = _target_rotation
	
	# Check progression
	_current_progress += _move_speed * delta
	_path_follow.progress = _current_progress
	if _path_follow.progress_ratio >= 0.99:
		return Status.Succeeded
	else:
		return Status.Running


func on_end():
	_path_follow.progress = 0
