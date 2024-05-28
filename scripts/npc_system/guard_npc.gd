class_name GuardNPC
extends AmbientNPCBase

@export var target_position_storage: Node3D


func _initialize_blackboard():
	super._initialize_blackboard()
	blackboard.append("Agent", _nav_agent)	
	

func _initialize_tree():
	_current_tree = SequenceNode.new([
		WaitTask.new(3, self),
		DebugTask.new("Starting Walk"),
		MoveTask.new(target_position_storage.global_position),
		DebugTask.new("Walking Complete"),		
		])
