class_name RandomNode
extends DecoratorNode

## Decorator Node that has a random chance to run

var _status
var _probability

func _init(child_node: BTNode, probability: float):
	super(child_node)
	_probability = probability


func on_start():
	var random = randf()
	# If we do not need to perform the child node, we are already done
	if  random > _probability:
		_status = Status.Succeeded
	else:
		_status = Status.Running
		_child.on_start()
		
		
func on_process(delta) -> Status:
	if _status == Status.Succeeded:
		return _status

	return _child.on_process(delta)
