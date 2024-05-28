## Uses an array of points to move along.
class_name MoveAlongPathTask
extends BTNode

var _owner: Node3D
var _points: Array[Vector3]
var _move_speed: float
var _current_point_index: int
var _current_target_pos: Vector3
var _threshold


func _init(points: Array[Vector3], threshold = 0.1):
	_points = points
	_threshold = threshold
	
	
func on_start():
	_owner = _blackboard.read("Base")
	_move_speed = _blackboard.read("Move Speed")
	_current_point_index = 0
	_current_target_pos = _points[_current_point_index]
	

func on_process(delta) -> Status:
	# Check progression
	if _owner.global_position.distance_to(_current_target_pos) < _threshold:
		_current_point_index += 1
		if _current_point_index < _points.size():
			_current_target_pos = _points[_current_point_index]
		else:
			return Status.Succeeded
	
	# Movement
	var direction = _owner.global_position.direction_to(_current_target_pos)
	var movement = direction.normalized() * delta * _move_speed
	_owner.global_position += movement
	
	return Status.Running
