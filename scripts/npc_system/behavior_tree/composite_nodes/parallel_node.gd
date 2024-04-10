class_name ParallelNode
extends BTNode

## @experimental has not been tested!
## Composite node that runs all its child nodes simultaneously.
## Fails when ANY of its children have failed.## Succeeeds when ALL of its children have succeeded.

var _child_nodes: Array

func _init(child_nodes: Array[BTNode]):
	_child_nodes = child_nodes
	
	
func on_process(delta):
	var child_statusses = []
	
	for node: BTNode in _child_nodes:
		child_statusses.append(node.on_process(delta))
	
	var any_child_running
	for status: Status in child_statusses:
		# Fail if any node has failed.
		if status == Status.Failed:
			return Status.Failed
		# Continue if a node is still running.			
		elif status == Status.Running:
			any_child_running = true
	
	if any_child_running:
		return Status.Running
	else:
		return Status.Succeeded
