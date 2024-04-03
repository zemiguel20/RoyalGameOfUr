class_name Blackboard

var shared_variables: Dictionary

func append(key, value):
    shared_variables[key] = value

    
func read(key):
    return shared_variables[key]


func remove(key):
    shared_variables.erase(key)