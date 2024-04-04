class_name KitchenTask
extends NPCTask

## The cooking task consists of playing an animation and waiting for a certain time.

var _wait_time: float
var _status: Status
var _npc: AmbientNPC

func _init(time, npc):
	_wait_time = time
	_npc = npc


func on_start():
	_npc.set_material_color(Color.LAWN_GREEN)
	
	_status = Status.Running
	await _npc.get_tree().create_timer(_wait_time).timeout
	_status = Status.Succeeded


func on_process(_delta) -> Status:
	return _status

func on_end():
	_npc._npc_manager.kitchen.leave()
