class_name MoveTask
extends NPCTask

var _target_position: Vector3
var _threshold = 0.1
var _npc

func _init(position, npc):
	_target_position = position
	_npc = npc


# Get ... from blackboard.
func on_process(delta) -> Status:
	if _target_position.distance_to(_npc.global_position) < _threshold:
		return Status.Succeeded

	# Movement Stuff
	_npc.global_position = _npc.global_position.move_toward(_target_position, _npc.move_speed * delta)
	return Status.Running
