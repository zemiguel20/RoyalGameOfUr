class_name BTNode
extends Node

enum Status 
{
	Failed = -1,
	Running = 0,
	Succeeded = 1
}

func on_start():
	pass
	
func on_process(_delta):
	pass
	
## @experimental Not sure how to make this one work yet
func on_physics_process(_delta):
	pass
	
func on_end():
	pass