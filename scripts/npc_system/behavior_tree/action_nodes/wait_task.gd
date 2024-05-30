class_name WaitTask
extends BTNode

var _wait_time: float
var _status: Status
var _owner

func _init(time):
	_wait_time = time


func on_start():
	_status = Status.Running
	# Get the owner, since we need a node to wait
	_owner = _blackboard.read("Base")
	await _owner.get_tree().create_timer(_wait_time).timeout
	_status = Status.Succeeded
	

func on_process(_delta) -> Status:
	return _status
	
