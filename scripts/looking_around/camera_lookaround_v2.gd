class_name CameraLookAroundV2
extends Camera3D

## In this variant, we will basically follow the mouse whenever it is inside of a border.
## It is like a normal looking around controller you would have in a first person game,
## with the exception that the looking around is only enabled when you are in a [MouseHoverBorder].


## Max degrees for camera rotation in all directions. 
@export var max_degrees: float = 15
@export var rotation_speed: float = 0.05
@export var centering_speed: float = 0.5

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
var _enable_looking = false


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	original_rotation = rotation	# Local rotation
	
	min_rotation_x = rotation_degrees.x - max_degrees
	max_degrees_x = rotation_degrees.x + max_degrees
	min_rotation_y = rotation_degrees.y - max_degrees
	max_degrees_y = rotation_degrees.y + max_degrees
	
	
func _process(delta):
	# Cache the delta: time between this and previous frame.
	_delta = delta	
	
	# FIXME:
	rotation.z = 0
	
	if _is_centering and not _enable_looking:
		centre()
		
		
func _input(event):
	#if event is InputEventKey:
		#if event.keycode == KEY_SPACE and event.is_pressed():
			#_enable_looking = not _enable_looking
	
	if not event is InputEventMouseMotion or not _enable_looking:
		return
		
	var mouseMotionEvent = event as InputEventMouseMotion
	var mouseDelta = mouseMotionEvent.relative as Vector2
	
	rotate(Vector3.UP, rotation_speed * _delta * -mouseDelta.x)
	rotate(Vector3.RIGHT, rotation_speed * _delta * -mouseDelta.y)		
		
		
func enable_looking():
	_enable_looking = true
	
	
func disable_looking():
	_enable_looking = false
	
	
func centre():
	if rotation.distance_to(original_rotation) > _threshold:
		rotation = rotation.move_toward(original_rotation, centering_speed * _delta)
	else:
		rotation = original_rotation
		_is_centering = false
		
	
func start_centre():
	_is_centering = true
	
