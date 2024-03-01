class_name Die
extends RigidBody3D

signal roll_finished(value: int)

@export_category("Throwing Physics")
## Magnitude of the throwing force applied to this die when starting a roll.
@export var throwing_force_magnitude : float = 1.0
## Angular velocity applied to this die when starting a roll.
@export var throwing_angular_velocity : float = 1.0

## Not sure if this is the best name for this variable.
## Makes sure that when throwing the dice from a hand, the dice spawn in apart from each other.
## The dice have a random offset from eachother equal to:
## [code] Vector3(randf_range(-_random_dice_offset, _random_dice_offset), 0, randf_range(-_random_dice_offset, _random_dice_offset)) [/code]
@export var _random_dice_offset = 1.0

@export_subgroup("Throwing Direction")
## X is min, Y is max
@export var throwing_force_direction_range_x = Vector2(-1, 1)
## X is min, Y is max
@export var throwing_force_direction_range_z = Vector2(-1, 1)

@onready var _highlighter: MaterialHighlighter = $MaterialHighlighter
@onready var _raycast_list: Array[DiceRaycast] = [$DiceRaycast1, $DiceRaycast2, $DiceRaycast3, $DiceRaycast4]

@export_category("Misc")
@export var _max_roll_duration: float

@onready var _rolling_timer: Timer = $Timer
var _throwing_position
var _is_rolling

func setup(_position: Vector3):
	_throwing_position = _position
	_rolling_timer.wait_time = _max_roll_duration
	_rolling_timer.start()

func highlight() -> void:
	if _highlighter != null:
		_highlighter.highlight()


func dehighlight() -> void:
	if _highlighter != null:
		_highlighter.dehighlight()
		

func roll() -> void:
	# Position the dice as if they just came out of a 'hand'
	var random_x = randf_range(-_random_dice_offset, _random_dice_offset)
	var random_z = randf_range(-_random_dice_offset, _random_dice_offset)
	var random_offset = Vector3(random_x, 0, random_z)
	global_position = _throwing_position + random_offset
	
	# Give the dice a random rotation (Basis) when they exit the 'hand'
	var random_rotation_x = randf_range(-180, 180)
	var random_rotation_y = randf_range(-180, 180)
	var random_rotation_z = randf_range(-180, 180)
	basis = Basis.from_euler(Vector3(random_rotation_x, random_rotation_y, random_rotation_z))	
	
	# Apply force in a random direction
	var random_direction_x = randf_range(throwing_force_direction_range_x.x, throwing_force_direction_range_x.y)
	var random_direction_z = randf_range(throwing_force_direction_range_z.x, throwing_force_direction_range_z.y)
	var throw_direction = Vector3(random_direction_x, 0, random_direction_z).normalized()
	var throw_force = throw_direction * throwing_force_magnitude
	apply_impulse(throw_force)
	#apply_torque_impulse(throw_direction * throwing_angular_velocity)
	
	_is_rolling = true
	
	# A timer specifying a maximum rolling duration.
	# If the 'rolling' did not stop already, it will stop after the timer and roll again.
	# Stuck timer prevents infinite waiting for small movements
	_rolling_timer.wait_time = _max_roll_duration
	_rolling_timer.start()
	_rolling_timer.timeout.connect(_on_timer_timeout)
		
		
func _on_timer_timeout():
	_on_movement_stopped()
		
		
func _on_movement_stopped():
	#TODO: Take another look!
	
	# Prevents 
	if (not _is_rolling):
		return
		
	if (not _is_rolling and not sleeping):
		return
	
	_rolling_timer.timeout.disconnect(_on_timer_timeout)
	
	# Retrieve roll value
	var roll_value = -1
	for raycast in _raycast_list:
		if raycast.is_colliding():
			roll_value = raycast.opposite_side_value
			break
	
	# If stuck, roll again
	if roll_value == -1:
		roll()
	else:
		_is_rolling = false
		roll_finished.emit(roll_value)
