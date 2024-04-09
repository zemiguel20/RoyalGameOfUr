class_name SelectorNode
extends BTNode

var current_index
var _child_nodes: Array

func _init(child_nodes: Array[BTNode]):
	_child_nodes = child_nodes

func on_start():
	current_index = 0
	
func on_process(_delta):
	var child_status = _child_nodes[current_index]
	if child_status != Status.Failed:
		return child_status
		
	# When a node fails, move to the next child, or finish if this was the last one.
	current_index += 1
	if current_index == _child_nodes.size():
		return Status.Failed
	
func on_physics_process(_delta):
	current_index = 0
	
func on_end():
	pass
