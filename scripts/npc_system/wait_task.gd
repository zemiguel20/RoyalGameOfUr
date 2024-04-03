class_name WaitTask
extends NPCTask

var _wait_time: float
var _status: Status
var _npc

func _init(time, npc):
	_wait_time = time
	_npc = npc


func on_start():
	_status = Status.Running
	await _npc.get_tree().create_timer(_wait_time).timeout
	_status = Status.Succeeded
	print("Done")


func on_process(_delta) -> Status:
	return _status
