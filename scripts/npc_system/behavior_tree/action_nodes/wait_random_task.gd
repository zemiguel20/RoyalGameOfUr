class_name WaitRandomTask
extends BTNode

var _min_wait_time: float
var _max_wait_time: float
var _status: Status
var _owner

func _init(min_wait_time, max_wait_time):
	_min_wait_time = min_wait_time
	_max_wait_time = max_wait_time
	

func on_start():
	_status = Status.Running
	# Get the owner, since we need a node to wait
	_owner = _blackboard.read("Base")
	var duration = randf_range(_min_wait_time, _max_wait_time)
	await _owner.get_tree().create_timer(duration).timeout
	_status = Status.Succeeded
	

func on_process(_delta) -> Status:
	return _status
	
