## This task is used for letting NPCs use the dialogue system
class_name PlayDialogueTask
extends BTNode

var _category: DialogueSystem.Category
var _wait_until_dialogue_end: bool
var _status

func _init(category: DialogueSystem.Category, wait_until_dialogue_end: bool):
	_category = category
	_wait_until_dialogue_end = wait_until_dialogue_end
	
	
func on_start():
	var dialogue_system = _blackboard.read("Dialogue System") as DialogueSystem
	
	_status = Status.Running if _wait_until_dialogue_end else Status.Succeeded 
	await dialogue_system.play(_category)
	_status = Status.Succeeded
	
	
func on_process(delta):
	return _status

