## Warps the owner to the [param _target_pos].
class_name WarpTask
extends BTNode

var _target_pos


func _init(target_position):
	_target_pos = target_position


func on_process(delta) -> Status:
	var owner = _blackboard.read("Base")
	owner.global_position = _target_pos
	return Status.Succeeded
