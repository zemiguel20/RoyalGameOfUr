class_name GuardNPC
extends AmbientNPCBase

#@export var _target_position_storage: Node3D
@export var _path: Path3D
@export var _move_speed: float

var _path_points: Array[Vector3]
var _original_position: Vector3

func on_ready(_npc_manager):
	_original_position = global_position
	for i in _path.curve.point_count:
		_path_points.append(_path.curve.get_point_position(i) + _path.global_position)
		
	super.on_ready(_npc_manager)
	

func _initialize_blackboard():
	super._initialize_blackboard()
	blackboard.append("Move Speed", _move_speed)


func _initialize_tree():
	## NOTE: For when the guard commentates, we can make a slightly different behaviour tree, 
	## that uses another path for example, or only the last few points of the path.
	_current_tree = SequenceNode.new([
		WaitTask.new(3, self),
		MoveAlongPathTask.new(_path_points),
		WarpTask.new(_original_position)
		])
