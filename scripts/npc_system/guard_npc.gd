class_name GuardNPC
extends AmbientNPCBase

@export_group("Paths & Routes")
@export var _path: PathFollow3D
@export var _path2: PathFollow3D
@export var _path3: PathFollow3D

@export_group("Speed")
@export var _move_speed: float = 2
@export var _rotation_speed: float = 1
@export var _walk_by_cooldown = 10

@export_group("Special Events")
## The guard has a random chance to wait at one of the points in the path.
@export_range(0, 1) var _watch_game_probability = 0.5
@export var _waiting_point_index = 1

var _original_position: Vector3

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
		MoveAlongPathTask.new(_path, 0.001, 0.3),		
		WaitTask.new(5),
		MoveAlongPathTask.new(_path, 0.3, 1),
		])
		
	_current_tree = SequenceNode.new([
		## Moving sequence with either watching the game or not stopping
		SelectorNode.new([
			RandomNode.new(_moving_sequence_with_wait, _watch_game_probability),
			_moving_sequence_no_wait
		]),
		WaitTask.new(_walk_by_cooldown),
		MoveAlongPathTask.new(_path2),
		WaitTask.new(_walk_by_cooldown),
		MoveAlongPathTask.new(_path3),
		## Warp back to starting position and wait
		WarpTask.new(_original_position),
		WaitRandomTask.new(_walk_by_cooldown, _walk_by_cooldown + 1)
		])
