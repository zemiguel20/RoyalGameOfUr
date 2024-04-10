class_name RandomNode
extends DecoratorNode

var _status
var _probability

func _init(child_node: BTNode, probability: float):
	_child = child_node
	probability = _probability


func _on_start():
	var random = randf()
	# If we do not need to perform the child node, we are already done
	if  random > _probability:
		_status = Status.Succeeded
		
		
func _on_process(delta) -> Status:
	if _status == Status.Succeeded:
		return _status

	return _child.on_process(delta)
