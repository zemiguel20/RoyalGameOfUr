## Camera with two modes: A fixed camera orientation mode looking at the board, 
## and a dynamic mode where we can freely look around.
class_name CameraLookAround
extends Camera3D

## Max degrees for camera rotation in all directions. 
@export var max_degrees: float = 35
## Sensitivity of the mouse in x and y. 
## TODO Make this a setting in the settings menu of the game in the future
@export var _looking_sensitivity: float = 0.1
@export var _centering_speed: float = .9
## Euler rotation in degrees of the fixed camera orientation used when looking at the board.
## The current orientation of the camera will be used as a default for the looking orientation.
@export var _board_look_rotation := Vector3(-30, 32, 0)
## When the rotation in degrees is lower than this value in the x axis, 
## the camera will switch back to the fixed board camera.
## Message to Ze: Alternatively, I could also change this variable to be relative to the board rotation and looking rotation.
## So this value would have a range of (0, 1) and we do an inverse lerp with the rotation to check if the camera is closer to the looking rotation or the board rotation.
## Example: If look_rot = (0, 30, 0), board_rot = (-40, 30, 0) and we are currently at (-30, 30, 0) our score would be 0.75. So here we would specify which score we need to switch.
@export var switch_threshold_degrees_x: float = -23

@export_group("Self References")
## Upon hovering over this ui element, the camera will switch to the looking around mode.
@onready var _looking_border = $CanvasLayer_ModeChange/LookingBorder as Control	

var _looking_around_rotation: Vector3
var _min_rotation_x: float
var _max_rotation_x: float
var _min_rotation_y: float
var _max_rotation_y: float

## Bool indicating whether looking around is currently enabled.
var _is_enabled = false
## Cached delta used for rotation in input method.
var _delta: float


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	_define_main_orientations()
	_define_constraints()
	
	await get_tree().create_timer(.5).timeout
	_return_to_board()
	_looking_border.mouse_entered.connect(_enter_looking_mode)
	
	
func _process(delta):
	# Cache the delta: time between this and previous frame.
	_delta = delta	

		
func _input(event):
	if not _is_enabled or not event is InputEventMouseMotion:
		return
	
	# Rotate based on mouse movement.	
	var mouseMotionEvent = event as InputEventMouseMotion
	var mouseDelta = mouseMotionEvent.relative as Vector2
	rotate(Vector3.UP, _looking_sensitivity * _delta * -mouseDelta.x)		# Looking left and right
	rotate_object_local(Vector3.RIGHT, _looking_sensitivity * _delta * -mouseDelta.y) 	# Looking up and down	
	
	# Constrain Rotations
	rotation.x = clampf(rotation.x, _min_rotation_x, _max_rotation_x)
	rotation.y = clampf(rotation.y, _min_rotation_y, _max_rotation_y)
	
	# If the player looks down at the board, exit looking around mode.
	if rotation.x - _looking_around_rotation.x < deg_to_rad(switch_threshold_degrees_x):
		_return_to_board()
		
		
func _define_main_orientations():
	_looking_around_rotation = global_rotation
	_board_look_rotation = General.deg_to_rad(_board_look_rotation)
	
	
func _define_constraints():
	var max_radians = deg_to_rad(max_degrees)
	_min_rotation_x = _looking_around_rotation.x - max_radians
	_max_rotation_x = _looking_around_rotation.x + max_radians
	_min_rotation_y = _looking_around_rotation.y - max_radians
	_max_rotation_y = _looking_around_rotation.y + max_radians	
		
		
func _return_to_board():
	_is_enabled = false	
	await _rotate_with_speed(_board_look_rotation, _centering_speed)
	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED	
	_looking_border.visible = true	


## Triggered when hovering over the looking around border.
func _enter_looking_mode():
	_looking_border.visible = false
	await _rotate_with_speed(_looking_around_rotation, _centering_speed)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_is_enabled = true
	
	
func _rotate_with_speed(target_global_euler: Vector3, speed: float):
	var duration = target_global_euler.distance_to(global_rotation) / speed
	
	var tween_rot = create_tween()
	tween_rot.bind_node(self).set_parallel(true)
	tween_rot.tween_property(self, "global_rotation:x", target_global_euler.x, duration)
	tween_rot.tween_property(self, "global_rotation:y", target_global_euler.y, duration)
	
	await tween_rot.finished
