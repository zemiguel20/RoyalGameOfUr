## The guard is an AmbientNPC, that patrols the area and occasionally watches the game.
class_name GuardNPC
extends AmbientNPCBase

@export_group("Paths & Routes")
@export var _path: PathFollow3D
@export var _path2: PathFollow3D
@export var _path3: PathFollow3D

@export_group("Speed")
@export var _move_speed: float = 2
@export var _walk_rotation_speed: float = 1
@export var _standing_rotation_speed: float = 1

@export_group("Timings")
@export var _start_delay = 20
@export var _min_walk_cooldown = 5
@export var _max_walk_cooldown = 20

@export_group("Special Events")
## The guard has a random chance to wait at one of the points in the path.
@export_range(0, 1) var _watch_game_probability = 0.5
## The part of the path follow where the guard pauzes.
@export var _watch_path_progress_ratio = 0.3

var _original_position: Vector3

func on_ready(_npc_manager):
	_original_position = global_position
	super.on_ready(_npc_manager)
	

func _initialize_blackboard():
	super._initialize_blackboard()
	blackboard.append("Move Speed", _move_speed)
	blackboard.append("Rotation Speed", _walk_rotation_speed)
	blackboard.append("Standing Rotation Speed", _standing_rotation_speed)


func _initialize_tree():
	## Subtree for traversing path 1
	var _moving_sequence_no_watching = SequenceNode.new([
		MoveAlongPathTask.new(_path)])
		
	## Subtree for traversing path 1, but stopping to watch the game.	
	var _moving_sequence_with_watching = SequenceNode.new([
		MoveAlongPathTask.new(_path, 0.001, _watch_path_progress_ratio),
		PlayAnimationTask.new("TurnLeft", true),
		RotateYTask.new(0.5*PI),
		DebugTask.new("Turned"),
		## Not sure how to fix the obvious transitions
		PlayAnimationTask.new("Idle", false, 0),
		WaitTask.new(5),
		PlayAnimationTask.new("TurnRight", true),
		RotateYTask.new(-0.5*PI),
		PlayAnimationTask.new("Walk", false, 0),
		MoveAlongPathTask.new(_path, _watch_path_progress_ratio, 1),
		])
		
	## Main tree of the guard.
	_current_tree = SequenceNode.new([
		RunOnceNode.new(WaitTask.new(_start_delay)),
		SetVisibilityTask.new(true),
		PlayAnimationTask.new("Walk"),
		## Moving sequence with either watching the game or not stopping.
		SelectorNode.new([
			RandomNode.new(_moving_sequence_with_watching, _watch_game_probability),
			_moving_sequence_no_watching
		]),
		SetVisibilityTask.new(false),		
		WaitRandomTask.new(_min_walk_cooldown, _max_walk_cooldown),
		## Wait and traverse path 2
		SetVisibilityTask.new(true),
		MoveAlongPathTask.new(_path2),
		SetVisibilityTask.new(false),		
		## Wait and traverse path 3		
		WaitRandomTask.new(_min_walk_cooldown, _max_walk_cooldown),
		SetVisibilityTask.new(true),		
		MoveAlongPathTask.new(_path3),
		SetVisibilityTask.new(false),
		## Warp back to starting position and wait
		WarpTask.new(_original_position),
		WaitRandomTask.new(_min_walk_cooldown, _max_walk_cooldown),
		])
