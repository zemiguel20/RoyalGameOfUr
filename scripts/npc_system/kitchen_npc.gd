class_name KitchenNPC
extends AmbientNPCBase

@export_group("Paths & Routes")
@export var _path: PathFollow3D
@export var _path2: PathFollow3D

@export_group("Speed")
@export var _move_speed: float = 2
@export var _rotation_speed: float = 1
@export var _standing_speed: float = 2.5

@export_group("Timing")
@export var _start_delay: float = 5
@export var _min_search_time: float = 30
@export var _max_search_time: float = 70
@export var _min_kitchen_time: float = 10
@export var _max_kitchen_time: float = 30

@export_group("Misc")
@export var _storage_point: Marker3D

var _original_position: Vector3


func on_ready(_npc_manager):
	_original_position = global_position
	
	super.on_ready(_npc_manager)
	

func _initialize_blackboard():
	super._initialize_blackboard()
	blackboard.append("Move Speed", _move_speed)
	blackboard.append("Rotation Speed", _rotation_speed)
	blackboard.append("Standing Rotation Speed", _standing_speed)


func _initialize_tree():
	_current_tree = SequenceNode.new([
		RunOnceNode.new(WaitTask.new(_start_delay)),
		SetVisibilityTask.new(true),
		PlayAnimationTask.new("Walk", false, 0),
		MoveAlongPathTask.new(_path),
		PlayAnimationTask.new("TurnRight", true),
		RotateYTask.new(-0.5 * PI),
		PlayAnimationTask.new("Browse", false, 0),
		WaitRandomTask.new(_min_search_time, _max_search_time),
		PlayAnimationTask.new("Walk", false, 0.15),		
		MoveAlongPathTask.new(_path2),
		SetVisibilityTask.new(false),
		WaitRandomTask.new(_min_kitchen_time, _max_kitchen_time)
		])
