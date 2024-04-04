class_name MoveTask
extends NPCTask

var _target_position: Vector3
var _threshold = 1.0
var _npc: AmbientNPC
var _nav_agent: NavigationAgent3D

func _init(position, npc, nav_agent):
	_target_position = position
	_npc = npc
	_nav_agent = nav_agent
	
	
func on_start():
	(_npc._mesh.get_active_material(0) as BaseMaterial3D).albedo_color = Color.ORANGE
	_nav_agent.target_position = _target_position
	

# Get ... from blackboard.
func on_process(delta) -> Status:
	if _target_position.distance_to(_npc.global_position) < _threshold:
		return Status.Succeeded

	# Process Movement
	var next_path_position = _nav_agent.get_next_path_position()
	_npc.global_position = _npc.global_position.move_toward(next_path_position, _npc.move_speed * delta)
	return Status.Running
