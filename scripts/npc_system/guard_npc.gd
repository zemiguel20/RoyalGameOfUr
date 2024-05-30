class_name GuardNPC
extends AmbientNPCBase

@export var _path: PathFollow3D
@export var _path2: PathFollow3D
@export var _path3: PathFollow3D
## The guard has a random chance to wait at one of the points in the path.
@export var _waiting_point_index = 1
@export var _move_speed: float = 2
@export var _rotation_speed: float = 1
@export var _walk_by_cooldown = 10
@export_range(0, 1) var _watch_game_probability = 0.5

var _original_position: Vector3
var _all_path_points: Array[Vector3]
var _path_points_before_pause: Array[Vector3]
var _path_points_after_pause: Array[Vector3]


func on_ready(_npc_manager):
	_original_position = global_position
	
	super.on_ready(_npc_manager)
	

func _initialize_blackboard():
	super._initialize_blackboard()
	blackboard.append("Move Speed", _move_speed)
	blackboard.append("Rotation Speed", _rotation_speed)


func _initialize_tree():
	## NOTE: For when the guard commentates, we can make a slightly different behaviour tree, 
	## that uses another path for example, or only the last few points of the path.	
	var _moving_sequence_no_wait = SequenceNode.new([
		DebugTask.new("move no wait"),
		MoveAlongPathTask.new(_path)])
		
	var _moving_sequence_with_wait = SequenceNode.new([
		DebugTask.new("move with wait"),
		MoveAlongPointsTask.new(_path_points_before_pause),
		WaitTask.new(5, self),
		MoveAlongPointsTask.new(_path_points_after_pause),
		])
		
	_current_tree = SequenceNode.new([
		## Moving sequence with either watching the game or not stopping
		SelectorNode.new([
			RandomNode.new(_moving_sequence_with_wait, _watch_game_probability),
			_moving_sequence_no_wait
		]),
		MoveAlongPathTask.new(_path2),
		MoveAlongPathTask.new(_path3),
		## Warp back to starting position and wait
		WarpTask.new(_original_position),
		WaitTask.new(_walk_by_cooldown, self),
		])
