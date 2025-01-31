## Uses an array of points to move along.
class_name MoveAlongPathTask
extends BTNode

var _owner: Node3D
var _path_follow: PathFollow3D
var _move_speed: float
var _rotation_speed: float


var _current_progress
var _target_rotation
var _progress_ratio_start
var _progress_ratio_goal


func _init(path_follow: PathFollow3D, progress_ratio_start = 0.001, progress_ratio_goal = 1):
	_path_follow = path_follow
	_progress_ratio_start = progress_ratio_start
	_progress_ratio_goal = progress_ratio_goal
	

func on_start():
	_owner = _blackboard.read("Base")
	_move_speed = _blackboard.read("Move Speed")
	_rotation_speed = _blackboard.read("Rotation Speed")
	
	_path_follow.progress_ratio = _progress_ratio_start
	_current_progress = _path_follow.progress
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
	if _path_follow.progress_ratio >= _progress_ratio_goal:
		return Status.Succeeded
	else:
		return Status.Running
