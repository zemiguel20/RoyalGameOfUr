extends AmbientNPCBase

@export var _test_marker: Marker3D
var _standing_rotation = 1.5

func _ready():
	on_ready(null)


func _initialize_blackboard():
	super._initialize_blackboard()
	blackboard.append("Standing Rotation Speed", _standing_rotation)


func _initialize_tree():
	_current_tree = SequenceNode.new([
		RotateTowardsPointTask.new(_test_marker.global_position),
		WaitTask.new(4)
	])
