class_name Die
extends RigidBody3D


signal roll_finished(value: int)

@export_category("Throwing Physics")
## Magnitude of the throwing force applied to this die when starting a roll.
@export var throwing_force_magnitude : float = 1.0
## Angular velocity applied to this die when starting a roll.
@export var throwing_angular_velocity : float = 1.0

## Height (y-value) of the die when it is released
@export var throwing_height : float = 2.0

## Not sure how to name this variable yet...
## Makes sure that when throwing the dice from a hand, the dice spawn in apart from each other.
## The dice have a random offset from eachother equal to:
## Vector3(randf_range(-temp_random_offset_on_throw, temp_random_offset_on_throw), 0, randf_range(-temp_random_offset_on_throw, temp_random_offset_on_throw))
@export var temp_random_offset_on_throw = 1.0

@export_subgroup("Throwing Direction")
## X is min, Y is max
@export var throwing_force_direction_range_x = Vector2(-1, 1)
## X is min, Y is max
@export var throwing_force_direction_range_z = Vector2(-1, 1)

var _temp_original_position
@onready var _raycast_list: Array[DiceRaycast] = [$DiceRaycast1, $DiceRaycast2, $DiceRaycast3, $DiceRaycast4]


func _ready():
	_temp_original_position = global_position


func roll() -> void:
	# Position the dice as if they just came out of a 'hand'
	var random_offset = Vector3(randf_range(-temp_random_offset_on_throw, temp_random_offset_on_throw), 0, randf_range(-temp_random_offset_on_throw, temp_random_offset_on_throw))
	global_position = _temp_original_position + random_offset
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
	apply_torque_impulse(throw_direction * throwing_angular_velocity)
	#angular_velocity = throw_direction * throwing_angular_velocity
	
	# Wait until the movement stops. Stuck timer prevents infinite waiting for small movements
	await get_tree().create_timer(5.0).timeout
	
	
	# Retrieve roll value
	var roll_value = -1
	for raycast in _raycast_list:
		if raycast.is_colliding():
			roll_value = raycast.opposite_side_value
			break
	
	# If stuck, roll again
	if roll_value == -1:
		roll_value = await roll()
	else:
		roll_finished.emit(roll_value)
