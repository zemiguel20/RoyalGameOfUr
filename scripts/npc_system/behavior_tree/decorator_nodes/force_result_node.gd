class_name ForceResultNode
extends DecoratorNode

## Decorator Node that runs its child node, but forces to return a predefined status.

var _result: Status

func _init(child: BTNode, result: Status):
	super(child)
	_result = result


func on_process(delta) -> Status:
	var child_status = _child.on_process(delta)
	if child_status != Status.Running:
		return _result
	else:
		return Status.Running
