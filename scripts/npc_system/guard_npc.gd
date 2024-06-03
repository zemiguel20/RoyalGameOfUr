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
@export var _watch_point: Marker3D

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
	var _moving_sequence_no_watching = SequenceNode.new([
		MoveAlongPathTask.new(_path)])
		
	var _moving_sequence_with_watching = SequenceNode.new([
		## TODO: No magic numbers!
		MoveAlongPathTask.new(_path, 0.001, 0.3),
		RotateTowardsPointTask.new(_watch_point.global_position),
		WaitTask.new(5),
		RotateTowardsPointTask.new(-(_path.global_position - _path.global_basis.z)),
		MoveAlongPathTask.new(_path, 0.3, 1),
		])
		
	_current_tree = SequenceNode.new([
		WaitTask.new(_start_delay),	
		## Moving sequence with either watching the game or not stopping
		SelectorNode.new([
			RandomNode.new(_moving_sequence_with_watching, _watch_game_probability),
			_moving_sequence_no_watching
		]),
		WaitRandomTask.new(_min_walk_cooldown, _max_walk_cooldown),
		MoveAlongPathTask.new(_path2),
		WaitRandomTask.new(_min_walk_cooldown, _max_walk_cooldown),
		MoveAlongPathTask.new(_path3),
		## Warp back to starting position and wait
		WarpTask.new(_original_position),
		WaitRandomTask.new(_min_walk_cooldown, _max_walk_cooldown),
		])
