class_name CameraLookAround
extends Camera3D

## Max degrees for camera rotation in all directions. 
@export var max_rotation: float = 15
@export var rotation_speed: float = 5

var original_rotation: Vector3
var min_rotation_x: float
var max_rotation_x: float
var min_rotation_y: float
var max_rotation_y: float

var _delta: float

var starting_forward
var starting_right
var starting_up


func _ready():
	original_rotation = rotation_degrees
	min_rotation_x = rotation_degrees.x - 15
	max_rotation_x = rotation_degrees.x + 15
	min_rotation_y = rotation_degrees.y - 15
	max_rotation_y = rotation_degrees.y + 15
	
	starting_forward = basis.z
	starting_right = basis.x
	starting_up = basis.y
	
	
func _process(delta):
	_delta = delta
	

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
	#if rotation_degrees.x >= max_rotation_x:
		#return
		
	#rotation_degrees += rotation_speed * _delta * Vector3.RIGHT
	rotate_object_local(Vector3.RIGHT, rotation_speed * _delta)		
	#rotate(starting_right, rotation_speed * _delta)	


func look_down():
	#if rotation_degrees.x <= min_rotation_x:
		#return
	
	#rotation_degrees += rotation_speed * _delta * -Vector3.RIGHT
	rotate_object_local(Vector3.RIGHT, -rotation_speed * _delta)	
	#rotate(starting_right, -rotation_speed * _delta)
	
	
	
func look_left():
	#if rotation_degrees.y <= min_rotation_y:
		#return
	
	#rotation_degrees += rotation_speed * _delta * Vector3.UP
	rotate_object_local(Vector3.UP, rotation_speed * _delta)	
	#rotate(starting_up, rotation_speed * _delta)		
	
func look_right():
	#if rotation_degrees.y >= max_rotation_y:
		#return

	#rotation_degrees += rotation_speed * _delta * -Vector3.UP
	rotate_object_local(Vector3.UP, -rotation_speed * _delta)	
	#rotate(starting_up, -rotation_speed * _delta)
	
	
#func vector_rad_to_deg(vector: Vector3) -> Vector3:
	#return Vector3(rad_to_deg(vector.x), rad_to_deg(vector.y), rad_to_deg(vector.z))
