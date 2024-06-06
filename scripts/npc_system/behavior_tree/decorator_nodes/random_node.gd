class_name RandomNode
extends DecoratorNode

## Decorator Node that has a random chance to run

var _status
var _probability
var _result_if_not_executing_child

func _init(child_node: BTNode, probability: float, result_if_not_executing_child = Status.Failed):
	super(child_node)
	_probability = probability
	_result_if_not_executing_child = result_if_not_executing_child


func on_start():
	var random = randf()
	# If we do not need to perform the child node, we are already done
	if  random > _probability:
		_status = _result_if_not_executing_child
	else:
		_status = Status.Running
		_child.on_start()
		
		
func on_process(delta) -> Status:
	if _status == Status.Running:
		return _child.on_process(delta)
	else:
		return _status

