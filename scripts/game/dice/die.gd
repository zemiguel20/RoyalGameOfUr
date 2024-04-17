class_name Die
extends RigidBody3D

signal roll_finished(value: int)

#region Export Variables
@export_category("Throwing Physics")
## Magnitude of the throwing force applied to this die when starting a roll.
@export var _throwing_force_magnitude: float = 1.0
## Angular velocity applied to this die when starting a roll.
@export var _throwing_angular_velocity: float = 1.0
## How long colliders are disable upon throwing. Can ofcourse be set to 0.
@export var _collision_disabling_duration: float = 0.05

@export_subgroup("Throwing Direction")
## X is min, Y is max
@export var _throwing_force_direction_range_x := Vector2(-1, 1)
## X is min, Y is max
@export var _throwing_force_direction_range_z := Vector2(-1, 1)

@export_category("Gravity")
@export var _mass_on_ground_multiplier: float = 2

@export_category("Extras")
@export var _floor_group: String = "Ground"
#endregion

#region Onready Variables
@onready var _highlighter: MaterialHighlighter = $MaterialHighlighter
@onready var _raycast_list: Array[DiceRaycast] = [$Raycasts/DiceRaycast1, $Raycasts/DiceRaycast2, $Raycasts/DiceRaycast3, $Raycasts/DiceRaycast4]
@onready var _rolling_timer: Timer = $RollTimeoutTimer
@onready var _collider: CollisionShape3D = $CollisionShape3D
#endregion

#region Private Variables
var _default_mass
var _mass_on_ground
var _roll_value

var _throwing_position
var _is_rolling
var _is_grounded

var _current_player
var _disable_collision = false
#endregion

func _ready():
	_default_mass = mass
	_mass_on_ground = mass * _mass_on_ground_multiplier
	
	
func highlight() -> void:
	if _highlighter != null:
		_highlighter.highlight()


func dehighlight() -> void:
	if _highlighter != null:
		_highlighter.dehighlight()
	# TODO: To disable the 'outline' highlight effect, we could add it here or create a seperate function
		

## Adds a highlight effect on the dice if it was a 1.	
## Currently not used.	
func outline_if_one() -> void:
	if _roll_value == 1:
		# In here we would use a different highligher class to apply some effect.
		#print("Highlight")
		pass
		
		
func roll(random_throwing_position: Vector3, invert_throwing_direction: bool) -> void:
	_disable_collision = true
	
	# Set some local variables
	_throwing_position = random_throwing_position
	
	# Set position and rotation
	global_position = random_throwing_position
	basis = _get_random_rotation()
	
	# Unfreeze the body to apply the throwing force.
	freeze = false
	mass = _default_mass
	_apply_throwing_force(invert_throwing_direction)
	
	# Disable the collider after a bit.
	await get_tree().create_timer(_collision_disabling_duration).timeout
	_disable_collision = false
	
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
func _physics_process(delta):
	if _disable_collision and not _collider.disabled:
		_collider.disabled = true
	elif not _disable_collision and _collider.disabled:
		_collider.disabled = false


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
		roll(_throwing_position, _current_player)
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
func _apply_throwing_force(invert: bool):
	var random_direction_x = randf_range(_throwing_force_direction_range_x.x, _throwing_force_direction_range_x.y)
	var random_direction_z = randf_range(_throwing_force_direction_range_z.x, _throwing_force_direction_range_z.y)
	var throw_direction = Vector3(random_direction_x, 0, random_direction_z).normalized()
	var inverse_direction = -1 if invert else 1 
	var throw_force = throw_direction * _throwing_force_magnitude * inverse_direction
	apply_impulse(throw_force)


## Loop through all raycasts in the dice to check if they are colliding..
## If yes, we return the corresponding value, else we return -1
func _check_roll_value():
	# The raycasts are set to only collide with the floor.
	for raycast in _raycast_list:
		if raycast.is_colliding():
			return raycast.opposite_side_value
			
	return -1
