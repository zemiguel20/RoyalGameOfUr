class_name GuardNPC
extends AmbientNPCBase

@export var _path: Path3D
## The guard has a random chance to wait at one of the points in the path.
@export var _waiting_point_index = 1
@export var _move_speed: float
@export var _walk_by_cooldown = 10
@export_range(0, 1) var _watch_game_probability = 0.5

var _original_position: Vector3
var _all_path_points: Array[Vector3]
var _path_points_before_pause: Array[Vector3]
var _path_points_after_pause: Array[Vector3]


func on_ready(_npc_manager):
	_original_position = global_position
	for i in _path.curve.point_count:
		_all_path_points.append(_path.curve.get_point_position(i) + _path.global_position)
		
	_path_points_before_pause = _all_path_points.slice(0, _waiting_point_index + 1)
	_path_points_after_pause = _all_path_points.slice(_waiting_point_index, _all_path_points.size())
	
	super.on_ready(_npc_manager)
	

func _initialize_blackboard():
	super._initialize_blackboard()
	blackboard.append("Move Speed", _move_speed)


func _initialize_tree():
	## NOTE: For when the guard commentates, we can make a slightly different behaviour tree, 
	## that uses another path for example, or only the last few points of the path.	
	var _moving_sequence_no_wait = SequenceNode.new([
		DebugTask.new("move no wait"),
		MoveAlongPathTask.new(_all_path_points)])
		
	var _moving_sequence_with_wait = SequenceNode.new([
		DebugTask.new("move with wait"),
		MoveAlongPathTask.new(_path_points_before_pause),
		WaitTask.new(5, self),
		MoveAlongPathTask.new(_path_points_after_pause),
		])
		
	_current_tree = SequenceNode.new([
		## Moving sequence with either watching the game or not stopping
		SelectorNode.new([
			RandomNode.new(_moving_sequence_with_wait, _watch_game_probability),
			_moving_sequence_no_wait
		]),
		## Warp back to starting position and wait
		WarpTask.new(_original_position),
		WaitTask.new(_walk_by_cooldown, self),
		])
