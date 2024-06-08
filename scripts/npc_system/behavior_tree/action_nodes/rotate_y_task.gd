## Rotates the owner in the direction of a specified point.
## Since the NPCs in this game will not lay down etc, we only rotate the Y axis.
class_name RotateYTask
extends BTNode

var _owner: Node3D
var _rotation_speed: float

var _direction
var _target_rotation
var _looking_point
var _status
var temp = 90

func _init(value):
	temp = value


func on_process(delta) -> Status:
	_owner = _blackboard.read("Base")
	_owner.rotate_y(temp)
	return Status.Succeeded

	
