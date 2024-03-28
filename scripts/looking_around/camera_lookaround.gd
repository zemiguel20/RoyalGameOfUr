class_name CameraLookAround
extends Camera3D

## NOTE: The camera object should have a local rotation of (0,0,0). 
## The rotation of the camera is defined by the Camera_Container parent.

## Max degrees for camera rotation in all directions. 
@export var max_degrees: float = 15
@export var rotation_speed: float = 5

var original_rotation: Vector3
var min_rotation_x: float
var max_degrees_x: float
var min_rotation_y: float
var max_degrees_y: float

var _delta: float
var _threshold: float = 0.001

var starting_forward
var starting_right
var starting_up

var _is_centering


func _ready():
	original_rotation = rotation	# Local rotation
	
	min_rotation_x = rotation_degrees.x - max_degrees
	max_degrees_x = rotation_degrees.x + max_degrees
	min_rotation_y = rotation_degrees.y - max_degrees
	max_degrees_y = rotation_degrees.y + max_degrees
	
	starting_forward = basis.z
	starting_right = basis.x
	starting_up = basis.y
	
	
func _process(delta):
	_delta = delta
	
	if _is_centering:
		centre()
	

func _input(event):
	if not event is InputEventKey:
		return 
		
	# Just for testing.
	if event.keycode == KEY_UP:
		look_up()
	if event.keycode == KEY_DOWN:
		look_down()
	if event.keycode == KEY_LEFT:
		look_left()
	if event.keycode == KEY_RIGHT:
		look_right()
		

func look_up():
	_is_centering = false
	if rotation_degrees.x >= max_degrees_x:
		return
		
	rotate_object_local(Vector3.RIGHT, rotation_speed * _delta)		


func look_down():
	_is_centering = false	
	if rotation_degrees.x <= min_rotation_x:
		return
	
	rotate_object_local(Vector3.RIGHT, -rotation_speed * _delta)	
	
	
func look_left():
	_is_centering = false	
	if rotation_degrees.y >= max_degrees_y:
		return
	
	rotate_object_local(Vector3.UP, rotation_speed * _delta)	
	
func look_right():
	_is_centering = false	
	if rotation_degrees.y <= min_rotation_y:
		return

	rotate_object_local(Vector3.UP, -rotation_speed * _delta)	
	
	
func centre():
	if rotation.distance_to(original_rotation) > _threshold:
		rotation = rotation.move_toward(original_rotation, rotation_speed * _delta)
	else:
		rotation = original_rotation
		_is_centering = false
		
	
func start_centre():
	_is_centering = true
	
