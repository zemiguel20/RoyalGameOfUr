class_name SequenceNode
extends BTNode

var current_index = 0
var _child_nodes: Array

func _init(child_nodes: Array[BTNode]):
	_child_nodes = child_nodes


func on_start():
	current_index = 0
	_child_nodes[current_index].on_start()

	
func on_process(_delta):
	var child_status = _child_nodes[current_index].on_process(_delta)
	if child_status != Status.Succeeded:
		return child_status
		
	# When success, move to the next child, or finish if this was the last one.
	_child_nodes[current_index].on_end()
	current_index += 1
	if current_index == _child_nodes.size():
		return Status.Succeeded
	else:
		_child_nodes[current_index].on_start()
		return Status.Running

	
func on_end():
	current_index = 0


func set_blackboard(blackboard: Blackboard):
	super.set_blackboard(blackboard)
	for child in _child_nodes:
		child.set_blackboard(blackboard)
