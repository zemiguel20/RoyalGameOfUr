## Rotates the owner in the direction of a specified point.
## Since the NPCs in this game will not lay down etc, we only rotate the Y axis.
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
	
	var owner_rotation = _owner.global_rotation
	_owner.look_at(_looking_point, Vector3.UP, true)
	_target_rotation = _owner.global_rotation
	_owner.global_rotation = owner_rotation
	
	_status = Status.Running
	# Calculate the shortest angle difference for the y-axis
	var difference_y = _shortest_angle_difference(_owner.global_rotation.y, _target_rotation.y)

	# Create the tween and rotate the object
	var tween = _owner.create_tween()
	tween.bind_node(_owner)
	tween.tween_property(_owner, "global_rotation:y", _owner.global_rotation.y + difference_y, abs(difference_y) / _rotation_speed)
	await tween.finished
	_status = Status.Succeeded


func on_process(delta) -> Status:
	return _status


# Function to calculate the shortest angle difference
func _shortest_angle_difference(from_angle, to_angle):
	var difference = wrapf(to_angle - from_angle, 0, 2 * PI)
	if difference > PI:
		difference -= 2 * PI
	return difference
	
