class_name AmbientNPC
extends PhysicsBody3D

var blackboard: Blackboard
var move_speed: float = 2
## NPC which is sort of a mix between state machine and behaviour tree.
var _npcData
var _current_task: NPCTask

@onready var _nav_agent = $NavigationAgent3D as NavigationAgent3D
@onready var _mesh = $Capsule_MeshInstance3D as MeshInstance3D

func _ready():
	_mesh.material_override = _mesh.material_override.duplicate()
	
	blackboard = Blackboard.new()
	blackboard.append("Base", self)

	_current_task = _choose_task()
	_current_task.on_start()
	
	
func _process(delta):
	var status = _current_task.on_process(delta)
	# If not running, chooses a new task and starts it.
	if status != NPCTask.Status.Running:
		_current_task.on_end()	# Might not be necassary
		_current_task = _choose_task()
		_current_task.on_start()
		

# Use the NPCManager/Data thing to check conditions like isKitchenClaimed
func _choose_task() -> NPCTask:
	var random = randi_range(1, 2)
	if random == 1:
		return WaitTask.new(randf_range(0.5, 2.5), self)
	else:
		var pos := Vector3(randf_range(-6.0, 6.0), global_position.y, randf_range(-6.0, 6.0))
		return MoveTask.new(pos, self, _nav_agent)
