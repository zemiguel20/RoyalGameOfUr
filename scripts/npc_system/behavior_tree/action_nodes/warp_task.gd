class_name WarpTask
extends BTNode

var _target_pos
var finished

func _init(target_position):
	_target_pos = target_position
	
	
func on_start():
	finished = false
	var owner = _blackboard.read("Base")
	owner.global_position = _target_pos
	finished = true


func on_process(delta) -> Status:
	return Status.Succeeded if finished else Status.Running
