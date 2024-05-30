## Uses an array of points to move along.
class_name MoveAlongPathTask
extends BTNode

var _owner: Node3D
var _path_follow: PathFollow3D
var _move_speed: float
var _threshold: float

var _progression_speed
var _current_progress


func _init(path_follow: PathFollow3D):
	_path_follow = path_follow


func on_start():
	_owner = _blackboard.read("Base")
	_move_speed = _blackboard.read("Move Speed")
	
	# Decide progression speed based on length of path.
	_current_progress = 0

	
func on_process(delta) -> Status:
	# Movement
	var prev_y_pos = _owner.global_position.y
	_owner.global_position = _path_follow.global_position
	_owner.global_position.y = prev_y_pos
	_owner.global_rotation = _path_follow.global_rotation
	
	# Check progression
	_current_progress += _move_speed * delta
	_path_follow.progress = _current_progress
	if _path_follow.progress_ratio >= 0.99:
		return Status.Succeeded
	else:
		return Status.Running


func on_end():
	_path_follow.progress	
