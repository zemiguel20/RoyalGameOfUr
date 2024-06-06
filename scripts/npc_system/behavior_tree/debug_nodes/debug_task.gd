class_name DebugTask
extends BTNode

var _text: String

func _init(text: String):
	_text = text

func on_process(_delta):
	print(_text)
	return Status.Succeeded
