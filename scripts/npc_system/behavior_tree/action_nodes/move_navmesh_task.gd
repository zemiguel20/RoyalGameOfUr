## @deprecated, we will likely not need pathfinding
class_name MoveNavAgentTask
extends BTNode

## Uses the NavigationAgent3D Component to move.

#var _target_position: Vector3
#var _threshold = 0.5
#var _npc: AmbientNPCBase
#var _nav_agent: NavigationAgent3D
#
#var failed
#
#func _init(position):
	#_target_position = position
	#
	#
#func on_start():
	#_npc = _blackboard.read("Base")
	#_nav_agent = _blackboard.read("Agent")
		#
	#_npc.set_material_color(Color.ORANGE)
	#_nav_agent.target_position = _target_position
	#
	#if not _nav_agent.is_target_reachable():
		#return Status.Failed
	#
	#_nav_agent.max_speed = _npc.move_speed
	#
#
#func on_process(delta) -> Status:
	#if failed:
		#return Status.Failed
	#
	#if _target_position.distance_to(_npc.global_position) < _threshold:
		#return Status.Succeeded
#
	#var next_path_position = _nav_agent.get_next_path_position()
	#next_path_position.y = _npc.original_height
	#_npc.global_position = _npc.global_position.move_toward(next_path_position, _npc.move_speed * delta)
	#return Status.Running
	#
#
### Processes movement, is for later
#func velocity_computed(safe_velocity):
	#pass
	##print("Velocity ", safe_velocity)
	##_npc.global_position += safe_velocity
