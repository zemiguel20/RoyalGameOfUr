class_name DecoratorNode
extends BTNode

var _child: BTNode

func _init(child_node: BTNode):
	_child = child_node

func on_start():
	_child.on_start()
	
func on_end():
	_child.on_end()
	
func set_blackboard(blackboard: Blackboard):
	super.set_blackboard(blackboard)
	_child.set_blackboard(blackboard)
