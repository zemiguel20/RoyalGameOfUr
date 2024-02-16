class_name Die
extends RigidBody3D

@export var throwing_force_magnitude = 1
@export var throwing_angular_velocity = 1

var is_rolling = false

signal roll_finished(roll_value : int)

func start_rolling():
	# Rotate the dice
	#transform.basis *= Basis(Vector3.RIGHT, randf_range(0, 2 * PI))
	#transform.basis *= Basis(Vector3.UP, randf_range(0, 2 * PI))
	#transform.basis *= Basis(Vector3.FORWARD, randf_range(0, 2 * PI))
	
	is_rolling = true
	
	# Apply force in a random direction
	var throw_direction = Vector3(randf_range(-1,1), 0, randf_range(-1,1)).normalized()
	var throw_force = throw_direction * throwing_force_magnitude
	angular_velocity = throw_force * throwing_angular_velocity
	apply_central_impulse(throw_force)

func _on_sleeping_state_changed():
	if (not is_rolling or not sleeping): return
	
	var roll = randi_range(0,1)
	emit_signal("roll_finished", roll)
	is_rolling = false
