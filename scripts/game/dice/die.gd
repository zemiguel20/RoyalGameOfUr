class_name Die
extends RigidBody3D

signal roll_finished(value: int)

#region Export Variables
@export_category("Throwing Physics")
## Magnitude of the throwing force applied to this die when starting a roll.
@export var _throwing_force_magnitude: float = 1.0
@export var _min_reroll_force_multiplier: float = 0.35
@export var _max_reroll_force_multiplier: float = 0.5

@export_category("Extras")
@export var _floor_group: String = "Ground"
@export var _mass_on_ground_multiplier: float = 2
@export var _down_accuracy_threshold: float = 0.8
## For each roll, dice are not allowed to evaluate their roll before this duration has passed.
## This makes sure that there will not be any early rerolls
@export var _min_roll_time: float = 1.0
## If true, dice that have an invalid roll will first try to apply a force on the side closest to the ground.
@export var _enable_landing_assist := true
#endregion

#region Onready Variables
@onready var _highlighter = $Highlighter as MaterialHighlighterComponent
@onready var _rolling_timer: Timer = $RollTimeoutTimer
#endregion

#region Private Variables
var _normal_list: Array[Node]
var _default_mass
var _mass_on_ground
var _roll_value

var _throwing_position
var _is_rolling := false
var _allow_check_roll := false
var _is_grounded := false

var _temp_check
#endregion

func _ready():
	Engine.time_scale = 3
	
	_rolling_timer.timeout.connect(_on_movement_stopped)
	
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	gravity_scale *= global_basis.get_scale().y
	_default_mass = mass
	_mass_on_ground = mass * _mass_on_ground_multiplier
	
	freeze = false
	_normal_list = get_node("Normals").get_children() as Array[Node]
	
	
func highlight() -> void:
	if _highlighter != null:
		_highlighter.active = true


func dehighlight() -> void:
	if _highlighter != null:
		_highlighter.active = false
	# TODO: To disable the 'outline' highlight effect, we could add it here or create a seperate function
		

## Adds a highlight effect on the dice if it was a 1.	
## Currently not used.	
func outline_if_one() -> void:
	if _roll_value == 1:
		# In here we would use a different highligher class to apply some effect.
		pass
		
		
func roll(throwing_spot: DiceSpot, is_reroll: bool = false) -> void:
	# Set some local variables
	_is_rolling = true
	can_sleep = false
	_throwing_position = throwing_spot
	
	# Set position and rotation
	global_transform.origin = throwing_spot.global_position
	basis = _get_random_rotation()
	
	# Unfreeze the body to apply the throwing force.
	mass = _default_mass
	freeze = false
	_is_grounded = false
	_apply_throwing_force(throwing_spot, is_reroll)
	
	# A timer specifying a maximum rolling duration.
	# If the 'rolling' did not stop already, it will stop after the timer and roll again.
	# Stuck timer prevents infinite waiting for small movements
	_rolling_timer.start()
	
	# Wait a short while before setting _is_rolling to true.
	# Immediately setting will trigger _on_movement_stopped with sleeping = false,
	# but since we set _is_rolling the same frame, the function will not return.
	
	await get_tree().create_timer(_min_roll_time).timeout
	can_sleep = true
	

## Triggers when the sleeping state of the rigidbody is changed.
## Checks the rolled value, and decides to either reroll or freeze and emit their value.
func _on_movement_stopped():
	if not _is_rolling or not _is_grounded or not can_sleep:
		return

	#print("Movement Stopped with temp_check: ", _temp_check)
	#print("Movement Stopped with can_sleep: ", can_sleep)
	_rolling_timer.stop() # Force timer stop in case triggered by physics sleep.
	
	# Retrieve roll value,
	_roll_value = -1
	_roll_value = await _check_roll_value()
	_temp_check = false
	
	# If stuck, roll again.
	if _roll_value == -1:
		roll(_throwing_position, true)
	# Else, reset some values and emit a signal.
	else:
		_is_rolling = false
		freeze = true
		mass = _default_mass
		roll_finished.emit(_roll_value)


## Triggers when the rigidbody collides.
## Used to increase the mass of a dice when it collides with the floor.
func _on_body_entered(body):
	if body.is_in_group(_floor_group):
		_is_grounded = true
		mass = _mass_on_ground


## Generates a random euler rotation, and return a Basis using this rotation.
## NOTE: Move to General if other scripts will use this too.
func _get_random_rotation() -> Basis:
	# Euler angles still use degrees.
	var random_rotation_x = randf_range(-180, 180)
	var random_rotation_y = randf_range(-180, 180)
	var random_rotation_z = randf_range(-180, 180)
	return Basis.from_euler(Vector3(random_rotation_x, random_rotation_y, random_rotation_z))	


## Throws the dice, by calculating a direction and applying an impulse force.
## [param playerID] is used to indicate if we should invert the throwing direction.
func _apply_throwing_force(dice_spot: DiceSpot, is_reroll: bool = false):
	var throw_direction = dice_spot.get_direction()
	var multiplier = dice_spot.throwing_velocity_multiplier
	var throw_velocity = throw_direction * _throwing_force_magnitude * global_basis.get_scale().x * multiplier
	if is_reroll:
		throw_velocity *= randf_range(_min_reroll_force_multiplier, _max_reroll_force_multiplier)
	
	## Setting velocity rather than applying force makes sure that the forces are not additive.
	linear_velocity = throw_velocity
	

## Loop through all normals in the dice to check how much they are facing down.
## If the most down facing normal is not meeting the requirements of the _down_accuracy_threshold, return -1
func _check_roll_value(is_second_check = false) -> int:
	var best_down_accuracy = 0.0
	var best_normal: DiceNormal
	
	for normal: DiceNormal in _normal_list:
		var down_direction = -normal.global_basis.y.normalized() # Get down direction of normal.
		var down_accuracy = down_direction.dot(Vector3.DOWN) # Use dot product to check if it is facing down in world space.
		if down_accuracy > best_down_accuracy:
			best_down_accuracy = down_accuracy
			best_normal = normal
	
	if best_down_accuracy > _down_accuracy_threshold:
		return best_normal.opposite_side_value
	elif _enable_landing_assist and not is_second_check:
		print("Second Chance!")
		_temp_check = true
		
		can_sleep = false
		apply_impulse(best_normal.global_basis.z * 2 * best_down_accuracy, best_normal.position)
		await get_tree().create_timer(0.6).timeout
		return await _check_roll_value(true)
	else:
		return -1
