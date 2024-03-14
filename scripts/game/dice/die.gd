class_name Die
extends RigidBody3D

signal roll_finished(value: int)

@export_category("Throwing Physics")
## Magnitude of the throwing force applied to this die when starting a roll.
@export var _throwing_force_magnitude : float = 1.0
## Angular velocity applied to this die when starting a roll.
@export var _throwing_angular_velocity : float = 1.0

## Not sure if this is the best name for this variable.
## Makes sure that when throwing the dice from a hand, the dice spawn in apart from each other.
## The dice have a random offset from eachother equal to:
## [code] Vector3(randf_range(-_random_dice_offset, _random_dice_offset), 0, randf_range(-_random_dice_offset, _random_dice_offset)) [/code]
@export var _random_dice_offset = 1.0

@export_subgroup("Throwing Direction")
## X is min, Y is max
@export var _throwing_force_direction_range_x = Vector2(-1, 1)
## X is min, Y is max
@export var _throwing_force_direction_range_z = Vector2(-1, 1)

@export_category("Gravity")
@export var _gravity_on_ground_multiplier = 2
@export var _floor_group = "Ground"

@onready var _highlighter: MaterialHighlighter = $MaterialHighlighter
@onready var _raycast_list: Array[DiceRaycast] = [$Raycasts/DiceRaycast1, $Raycasts/DiceRaycast2, $Raycasts/DiceRaycast3, $Raycasts/DiceRaycast4]
@onready var _rolling_timer: Timer = $RollTimeoutTimer
@onready var _collider: CollisionShape3D = $CollisionShape3D

var _default_gravity
var _mass_on_ground
var _roll_value

var _throwing_position
var _is_rolling
var _is_grounded

var _current_player

# TODO: Check if this is needed.
func setup(_position: Vector3):
	_throwing_position = _position
	_default_gravity = mass
	_mass_on_ground = mass * _gravity_on_ground_multiplier
	
	
func highlight() -> void:
	if _highlighter != null:
		_highlighter.highlight()


func dehighlight() -> void:
	if _highlighter != null:
		_highlighter.dehighlight()
		

## Adds a highlight effect on the dice if it was a 1.		
func outline_if_one() -> void:
	if _roll_value == 1:
		print("Highlight")
		
		
func roll(random_throwing_position: Vector3, playerID: General.PlayerID) -> void:
	_collider.disabled = true
	
	# Set some local variables
	_throwing_position = random_throwing_position
	_current_player = playerID
	
	# Set position and rotation
	global_position = random_throwing_position
	basis = get_random_rotation()
	
	# Unfreeze the body to apply the throwing force.
	freeze = false
	mass = _default_gravity
	apply_throwing_force(playerID)
	
	# Disable the collider after a bit.
	await get_tree().create_timer(0.05).timeout
	_collider.disabled = false
	
	# Wait a short while before setting _is_rolling to true.
	# Immediately setting will trigger _on_movement_stopped with sleeping = false,
	# but since we set _is_rolling the same frame, the function will not return.
	await get_tree().create_timer(0.1).timeout
	_is_rolling = true
	
	## A timer specifying a maximum rolling duration.
	## If the 'rolling' did not stop already, it will stop after the timer and roll again.
	## Stuck timer prevents infinite waiting for small movements
	_rolling_timer.start()


## Triggers when the sleeping state of the rigidbody is changed.
## Checks the rolled value, and decides to either reroll or freeze and emit their value.
func _on_movement_stopped():
	if not _is_rolling:
		return

	_rolling_timer.stop() # Force timer stop in case triggered by physics sleep.
	
	# Retrieve roll value,
	_roll_value = -1
	for raycast in _raycast_list:
		if raycast.is_colliding():
			_roll_value = raycast.opposite_side_value
			break
	
	# If stuck, roll again.
	if _roll_value == -1:
		roll(_throwing_position, _current_player)
	# Else, reset some values and emit a signal.
	else:
		_is_rolling = false
		freeze = true	
		mass = _default_gravity
		roll_finished.emit(_roll_value)


func _on_body_entered(body):
	if not _is_rolling:
		return
	
	if body.is_in_group(_floor_group):
		mass = _mass_on_ground
	
		
## Generates a random euler rotation, and return a Basis using this rotation.
## NOTE: Move to General if other scripts will use this too.
func get_random_rotation() -> Basis:
	# Euler angles still use degrees.
	var random_rotation_x = randf_range(-180, 180)
	var random_rotation_y = randf_range(-180, 180)
	var random_rotation_z = randf_range(-180, 180)
	return Basis.from_euler(Vector3(random_rotation_x, random_rotation_y, random_rotation_z))	


## Throws the dice, by calculating a direction and applying an impulse force.
func apply_throwing_force(playerID):
	var random_direction_x = randf_range(_throwing_force_direction_range_x.x, _throwing_force_direction_range_x.y)
	var random_direction_z = randf_range(_throwing_force_direction_range_z.x, _throwing_force_direction_range_z.y)
	var throw_direction = Vector3(random_direction_x, 0, random_direction_z).normalized()
	var inverse_direction = -1 if playerID == General.PlayerID.TWO else 1 
	var throw_force = throw_direction * _throwing_force_magnitude * inverse_direction
	apply_impulse(throw_force)
