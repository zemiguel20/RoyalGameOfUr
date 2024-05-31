## Uses an array of points to move along.
class_name RotateTowardsPointTask
extends BTNode

var _owner: Node3D
var _rotation_speed: float

var _target_rotation
var _looking_point
var _status

func _init(looking_point: Vector3):
	_looking_point = looking_point


func on_start():
	_owner = _blackboard.read("Base")
	_rotation_speed = _blackboard.read("Standing Rotation Speed")
	
	_target_rotation = _owner.global_basis.looking_at(_looking_point, Vector3.UP, true).get_euler()
	#_status = Status.Running
	#
	#var tween = _owner.create_tween()
	#tween.bind_node(_owner)
	#tween.tween_property(_owner, "global_basis:z", _direction, difference/speed)
	#await tween.finished
	#_status = Status.Succeeded
	

func on_process(delta) -> Status:
	var difference = _owner.global_rotation.distance_to(_target_rotation)
	var speed = _rotation_speed * delta
	if difference <= speed:
		_owner.global_rotation = _target_rotation
		return Status.Succeeded
	else:
		_owner.global_rotation = _owner.global_rotation.lerp(_target_rotation, speed/difference)
		return Status.Running
