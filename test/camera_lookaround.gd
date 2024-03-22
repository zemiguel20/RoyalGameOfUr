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


func _ready():
	print("Up vector: ", transform.basis.y)	
	
	original_rotation = rotation_degrees
	min_rotation_x = rotation_degrees.x - 15
	max_rotation_x = rotation_degrees.x + 15
	min_rotation_y = rotation_degrees.y - 15
	max_rotation_y = rotation_degrees.y + 15
	
	
func _process(delta):
	_delta = delta
	

func _input(event):
	if not event is InputEventKey:
		return 
		
	# Just for testing.
	if event.keycode == KEY_UP:
		lookup()
	if event.keycode == KEY_DOWN:
		lookdown()
	if event.keycode == KEY_LEFT:
		lookleft()
	if event.keycode == KEY_RIGHT:
		lookright()
		

func lookup():
	if rotation_degrees.x >= max_rotation_x:
		return
		
	rotation_degrees += rotation_speed * _delta * Vector3.RIGHT


func lookdown():
	if rotation_degrees.x <= min_rotation_x:
		return
	
	rotation_degrees += rotation_speed * _delta * -Vector3.RIGHT
	
	
func lookleft():
	if rotation_degrees.y >= min_rotation_y:
		return
	
	rotation_degrees += rotation_speed * _delta * Vector3.UP
	
	
func lookright():
	if rotation_degrees.y <= max_rotation_y:
		return

	rotation_degrees += rotation_speed * _delta * -Vector3.UP
	
	
func vector_rad_to_deg(vector: Vector3) -> Vector3:
	return Vector3(rad_to_deg(vector.x), rad_to_deg(vector.y), rad_to_deg(vector.z))
