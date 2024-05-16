class_name Die
extends RigidBody3D

signal roll_finished(value: int)

#region Export Variables
@export_category("Throwing Physics")
## Magnitude of the throwing force applied to this die when starting a roll.
@export var _throwing_force_magnitude: float = 1.0
@export var _min_reroll_force_multiplier: float = 0.2
@export var _max_reroll_force_multiplier: float = 0.5


@export_category("Extras")
@export var _floor_group: String = "Ground"
@export var _mass_on_ground_multiplier: float = 2
@export var _down_accuracy_threshold: float = 0.8
@export var _velocity_threshold: float = 0.05
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
var _is_rolling
#endregion

func _ready():
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
	_throwing_position = throwing_spot
	
	# Set position and rotation
	global_transform.origin = throwing_spot.global_position
	basis = _get_random_rotation()
	
	# Unfreeze the body to apply the throwing force.
	mass = _default_mass
	freeze = false
	_apply_throwing_force(throwing_spot, is_reroll)
	
	# Wait a short while before setting _is_rolling to true.
	# Immediately setting will trigger _on_movement_stopped with sleeping = false,
	# but since we set _is_rolling the same frame, the function will not return.
	await get_tree().create_timer(0.05).timeout
	_is_rolling = true
	
	# A timer specifying a maximum rolling duration.
	# If the 'rolling' did not stop already, it will stop after the timer and roll again.
	# Stuck timer prevents infinite waiting for small movements
	_rolling_timer.start()
	
	
## Changing the collision state should be done in _physics_process.
func _physics_process(_delta):
	if linear_velocity.length() < _velocity_threshold * global_basis.get_scale().x \
		and angular_velocity.length() < _velocity_threshold * global_basis.get_scale().x \
		and _is_rolling \
		and mass == _mass_on_ground:
		_on_movement_stopped()
	

## Triggers when the sleeping state of the rigidbody is changed.
## Checks the rolled value, and decides to either reroll or freeze and emit their value.
func _on_movement_stopped():
	if not _is_rolling:
		return

	_rolling_timer.stop() # Force timer stop in case triggered by physics sleep.
	
	# Retrieve roll value,
	_roll_value = _check_roll_value() 
	
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
	if not _is_rolling:
		return
	
	if body.is_in_group(_floor_group):
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
	var throw_force = throw_direction * _throwing_force_magnitude * global_basis.get_scale().x * multiplier
	if is_reroll:
		throw_force *= randf_range(_min_reroll_force_multiplier, _max_reroll_force_multiplier)
	
	## Setting velocity rather than applying force makes sure that the forces are not additive.
	linear_velocity = throw_force
	

## Loop through all normals in the dice to check how much they are facing down.
## If the most down facing normal is not meeting the requirements of the _down_accuracy_threshold, return -1
func _check_roll_value():
	var max_down_accuracy = 0.0
	var best_value = -1
	
	for normal: DiceNormal in _normal_list:
		var down_direction = -normal.global_basis.y.normalized() # Get down direction of normal.
		var down_accuracy = down_direction.dot(Vector3.DOWN) # Use dot product to check if it is facing down in world space.
		if down_accuracy > max_down_accuracy:
			max_down_accuracy = down_accuracy
			best_value = normal.opposite_side_value
	
	if max_down_accuracy > _down_accuracy_threshold:
		return best_value
	else:
		return -1
