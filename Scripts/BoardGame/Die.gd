class_name Die
extends RigidBody3D

@export var raycasts_parent_node : Node

@export var throwing_force_magnitude = 1
@export var throwing_angular_velocity = 1

var is_rolling = false
var raycast_list

signal roll_finished(roll_value : int)

func _ready():
	raycast_list = raycasts_parent_node.get_children()

func start_rolling():
	is_rolling = true
	
	# Apply force in a random direction
	var throw_direction = Vector3(randf_range(-1,1), 0, randf_range(-1,1)).normalized()
	var throw_force = throw_direction * throwing_force_magnitude
	angular_velocity = throw_force * throwing_angular_velocity
	apply_central_impulse(throw_force)

func _on_sleeping_state_changed():
	if (not is_rolling or not sleeping): return
	
	var roll = -1
	for raycast : DiceRaycast in raycast_list:
		if raycast.is_colliding():
			print((raycast.get_collider() as Node).name)
			roll = raycast.opposite_side_value
			break
	
	if roll == -1:
		push_error("No value detected ;(")
	else:
		emit_signal("roll_finished", roll)
		is_rolling = false
