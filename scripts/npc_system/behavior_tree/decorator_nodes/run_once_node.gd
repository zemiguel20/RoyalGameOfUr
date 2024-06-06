class_name RunOnceNode
extends DecoratorNode

## Behaviour Tree node that will only be completed one time. 
## When the tree repeats and this node is called, it will be skipped.

## Remembers if this node has been completed before.
var has_completed

func on_process(delta):
	if has_completed:
		return Status.Succeeded
	
	var child_status = _child.on_process(delta)
	
	if child_status != Status.Running:
		has_completed = true
		
	return child_status
