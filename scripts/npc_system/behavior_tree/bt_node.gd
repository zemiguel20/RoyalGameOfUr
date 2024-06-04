class_name BTNode
extends Node

enum Status 
{
	Failed = -1,
	Running = 0,
	Succeeded = 1
}

var _blackboard: Blackboard

func on_start():
	pass
	
func on_process(_delta):
	pass
	
func on_end():
	pass
	
func set_blackboard(blackboard: Blackboard):
	_blackboard = blackboard
