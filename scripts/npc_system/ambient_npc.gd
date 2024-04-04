class_name AmbientNPC
extends PhysicsBody3D

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
var is_moving_to_kitchen

func on_ready(manager: NPCDataManager):
	_npc_manager = manager
	_material = _mesh.material_override.duplicate()
	_mesh.material_override = _material
	
	#blackboard = Blackboard.new()
	#blackboard.append("Base", self)

	_current_task = _choose_task()
	_current_task.on_start()
	
	
func _process(delta):
	var status = _current_task.on_process(delta)
	# If not running, chooses a new task and starts it.
	if status != NPCTask.Status.Running:
		_current_task.on_end()	# Might not be necassary
		_current_task = _choose_task()
		_current_task.on_start()
		

# Helper method for showing different actions
func set_material_color(color: Color):
	(_mesh.material_override as BaseMaterial3D).albedo_color = color
	

# Use the NPCManager/Data thing to check conditions like isKitchenClaimed
func _choose_task() -> NPCTask:
	if _npc_manager.kitchen.claimer == self:
		return KitchenTask.new(randf_range(10, 15), self)
			
	var random = randi_range(1, 3)
	if random == 1:
		return WaitTask.new(randf_range(0.5, 2.5), self)
	elif random == 2:
		var pos := Vector3(randf_range(-6.0, 6.0), global_position.y, randf_range(-6.0, 6.0))
		print("Target Position:", pos)
		var task = MoveTask.new(pos, self, _nav_agent)
		_nav_agent.velocity_computed.connect(task.velocity_computed)
		return task
	elif random == 3:
		# So far this is all for testing purposes.
		if not _npc_manager.kitchen.is_claimed and not temp_has_claimed_kitchen:
			_npc_manager.kitchen.try_claim(self)
			temp_has_claimed_kitchen = true
			return MoveTask.new(_npc_manager.kitchen.global_position, self, _nav_agent)	

	return WaitTask.new(1.0, self)
