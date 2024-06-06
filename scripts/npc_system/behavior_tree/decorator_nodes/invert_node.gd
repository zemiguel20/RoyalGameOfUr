class_name InvertNode
extends DecoratorNode

## Returns Running (0) while child node is Running, 
## Returns Succeeded (1) when child node has Failed, 
## and returns Failed (-1) when child node has Succeeded
func on_process(delta) -> Status:
	var child_status = _child.on_process(delta)
	return child_status * -1
