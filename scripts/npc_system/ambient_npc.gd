class_name AmbientNPC
extends PhysicsBody3D

## These tasks refer to larger tasks, which are a collection of tasks.
## For example, the KitchenTask is a collection of walking, waiting etc.
enum NPCTaskType 
{
	NoTask = 0,
	WalkBy = 1,
	CookMeal = 2,
	Spectate = 3
}

@export var possible_tasks: Array[NPCTaskType] 

var blackboard: Blackboard
var move_speed: float = 2
## NPC which is sort of a mix between state machine and behaviour tree.
var _npcData
var _current_task: NPCTask

@onready var _nav_agent = $NavigationAgent3D as NavigationAgent3D
@onready var _mesh = $Capsule_MeshInstance3D as MeshInstance3D

var _material: BaseMaterial3D
var _npc_manager: NPCDataManager

var temp_has_claimed_kitchen
var original_height

func on_ready(manager: NPCDataManager):
	_npc_manager = manager
	_material = _mesh.material_override.duplicate()
	_mesh.material_override = _material
	
	original_height = global_position.y
	
	#blackboard = Blackboard.new()
	#blackboard.append("Base", self)

	_current_task = _choose_task_test()
	await Engine.get_main_loop().process_frame
	_current_task.on_start()
	
	
func _process(delta):
	var status = _current_task.on_process(delta)
	# If not running, chooses a new task and starts it.
	if status != NPCTask.Status.Running:
		_current_task.on_end()	# Might not be necassary
		_current_task = _choose_task_test()
		_current_task.on_start()
		
		
#func _physics_process(delta):
	#var status = _current_task.on_physics_process(delta)
	#
	## If not running, chooses a new task and starts it.
	#if status != NPCTask.Status.Running:
		#_current_task.on_end()	# Might not be necassary
		#_current_task = _choose_task_test()
		#_current_task.on_start()
	

# Helper method for showing different actions
func set_material_color(color: Color):
	(_mesh.material_override as BaseMaterial3D).albedo_color = color
	

func _choose_task() -> NPCTask:
	if possible_tasks.size() == 0:
		return DebugTask.new("Waitinggg")
		
	var random_task = possible_tasks.pick_random()
	
	if random_task == NPCTaskType.CookMeal:	
		return DebugTask.new("Cooking meal")
	elif random_task == NPCTaskType.WalkBy:	
		return DebugTask.new("Walkinn")	
	elif random_task == NPCTaskType.Spectate:	
		return DebugTask.new("Taking a looksie")

	return DebugTask.new("Waitinggg")
	

# Use the NPCManager/Data thing to check conditions like isKitchenClaimed
func _choose_task_test() -> NPCTask:
	if _npc_manager.kitchen.claimer == self:
		return KitchenTask.new(randf_range(10, 15), self)
			
	var random = randi_range(1, 3)
	if random == 1:
		return WaitTask.new(randf_range(0.5, 2.5), self)
	elif random == 2:
		var pos := Vector3(randf_range(-6.0, 6.0), original_height, randf_range(-6.0, 6.0))
		print("Target Position:", pos)
		var task = MoveTask.new(pos, self, _nav_agent)
		_nav_agent.velocity_computed.connect(task.velocity_computed)
		return task
	elif random == 3:
		# So far this is all for testing purposes.
		if not _npc_manager.kitchen.is_claimed and not temp_has_claimed_kitchen:
			_npc_manager.kitchen.try_claim(self)
			temp_has_claimed_kitchen = true
			_npc_manager.kitchen.global_position.y = original_height
			return MoveTask.new(_npc_manager.kitchen.global_position, self, _nav_agent)	

	return WaitTask.new(1.0, self)
