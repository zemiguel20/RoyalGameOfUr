class_name SetVisibilityTask
extends BTNode

var _visibility
var _owner

func _init(visibility):
	_visibility = visibility

func on_start():
	_owner = _blackboard.read("Base")
	

func on_process(_delta) -> Status:
	_owner.visible = _visibility
	return Status.Succeeded
	
