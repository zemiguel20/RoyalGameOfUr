## A Blackboard is a way to pass references and variables across classes,
## and is used in this project by owners of a behaviour tree. 
## This ensures that the owner of the tree does not have to pass the same references into multiple nodes.
class_name Blackboard

var shared_variables: Dictionary

func append(key, value):
	shared_variables[key] = value

	
func read(key):
	return shared_variables[key]


func remove(key):
	shared_variables.erase(key)
