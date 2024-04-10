class_name WaitTask
extends BTNode

var _wait_time: float
var _status: Status
var _npc

func _init(time, npc):
	_wait_time = time
	_npc = npc


func on_start():
	#(_npc._mesh.material_override as BaseMaterial3D).albedo_color = Color.RED
	
	_status = Status.Running
	await _npc.get_tree().create_timer(_wait_time).timeout
	_status = Status.Succeeded
	

func on_process(_delta) -> Status:
	return _status
	
