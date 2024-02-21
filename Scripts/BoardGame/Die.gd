class_name Die
extends RigidBody3D

#region Export Variables
@export_category("References")
## Reference to the parent node containing all raycasts.
## These raycasts are used to check the value of the dice throw.
@export var raycasts_parent_node : Node
@export var audio_player : AudioStreamPlayer3D

@export_category("Throwing Physics")
## Magnitude of the throwing force applied to this die when starting a roll.
@export var throwing_force_magnitude : float = 1.0
## Angular velocity applied to this die when starting a roll.
@export var throwing_angular_velocity : float = 1.0

## X is min, Y is max
@export var throwing_force_direction_range_x = Vector2(-1, 1)
## X is min, Y is max
@export var throwing_force_direction_range_z = Vector2(-1, 1)

## Height (y-value) of the die when it is released
@export var throwing_height : float = 2.0

## Not sure how to name this variable yet...
## Makes sure that when throwing the dice from a hand, the dice spawn in apart from each other.
## The dice have a random offset from eachother equal to:
## Vector3(randf_range(-temp_random_offset_on_throw, temp_random_offset_on_throw), 0, randf_range(-temp_random_offset_on_throw, temp_random_offset_on_throw))
@export var temp_random_offset_on_throw = 1.0
#endregion

#region Private Variables
var is_rolling = false
var raycast_list	
var temp_original_position
#endregion

signal roll_finished(roll_value : int)

func _ready():
	temp_original_position = global_position
	raycast_list = raycasts_parent_node.get_children()

func start_rolling():
	if (is_rolling):
		return
	
	is_rolling = true
	
	# Position the dice as if they just came out of a 'hand'
	var random_offset = Vector3(randf_range(-temp_random_offset_on_throw, temp_random_offset_on_throw), 0, randf_range(-temp_random_offset_on_throw, temp_random_offset_on_throw))
	global_position = temp_original_position + random_offset
	global_position.y = throwing_height
	
	# Give the dice a random rotation (Basis) when they exit the 'hand'
	var random_rotation_x = randf_range(0, 2 * PI)
	var random_rotation_y = randf_range(0, 2 * PI)
	var random_rotation_z = randf_range(0, 2 * PI)
	basis = Basis.from_euler(Vector3(random_rotation_x, random_rotation_y, random_rotation_z))	
	
	# Apply force in a random direction
	var random_x = randf_range(throwing_force_direction_range_x.x, throwing_force_direction_range_x.y)
	var random_z = randf_range(throwing_force_direction_range_z.x, throwing_force_direction_range_z.y)
	var throw_direction = Vector3(random_x, 0, random_z).normalized()
	var throw_force = throw_direction * throwing_force_magnitude
	
	apply_central_impulse(throw_force)
	angular_velocity = throw_direction * throwing_angular_velocity

# Triggers when the rigidbody:
# - Was sleeping but gains velocity
# - Was not sleeping but no longer has velocity left
func _on_sleeping_state_changed():
	if (not is_rolling or not sleeping): return
	
	var roll_value = -1
	for raycast : DiceRaycast in raycast_list:
		if raycast.is_colliding():
			print((raycast.get_collider() as Node).name)
			roll_value = raycast.opposite_side_value
			break
	
	if roll_value == -1:
		# TODO: Make sure this scenario can never happen.
		# For example by rolling and 
		push_warning("No value detected ;(")
		roll_value = 0
		
	emit_signal("roll_finished", roll_value)
	is_rolling = false
