class_name KitchenNPC
extends AmbientNPCBase

@export_group("Paths & Routes")
@export var _path: PathFollow3D
@export var _path2: PathFollow3D

@export_group("Speed")
@export var _move_speed: float = 2
@export var _rotation_speed: float = 1

@export_group("Timing")
@export var _start_delay: float = 5
@export var _min_search_time: float = 30
@export var _max_search_time: float = 70
@export var _min_kitchen_time: float = 10
@export var _max_kitchen_time: float = 30

var _original_position: Vector3


func on_ready(_npc_manager):
	_original_position = global_position
	
	super.on_ready(_npc_manager)
	

func _initialize_blackboard():
	super._initialize_blackboard()
	blackboard.append("Move Speed", _move_speed)
	blackboard.append("Rotation Speed", _rotation_speed)


func _initialize_tree():
	_current_tree = SequenceNode.new([
		RunOnceNode.new(WaitTask.new(_start_delay)),
		SetVisibilityTask.new(true),
		MoveAlongPathTask.new(_path),
		DebugTask.new("Playing animation! Replace me"),
		WaitRandomTask.new(_min_search_time, _max_search_time),
		MoveAlongPathTask.new(_path2),
		DebugTask.new("Waitin in the kitchen"),
		SetVisibilityTask.new(false),
		WaitRandomTask.new(_min_kitchen_time, _max_kitchen_time)
		])
