class_name ForceResultNode
extends DecoratorNode

var _result: Status

func _init(_child: BTNode, result: Status):
	_result = result

## Returns Running (0) while child node is Running, 
## Returns Succeeded (1) when child node has Failed, 
## and returns Failed (-1) when child node has Succeeded
func on_process(delta) -> Status:
	var child_status = _child.on_process(delta)
	if child_status != Status.Running:
		return _result
	else:
		return Status.Running
