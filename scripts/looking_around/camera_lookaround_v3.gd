class_name CameraLookAroundV3
extends Camera3D

## In this variant, we will basically follow the mouse whenever it is inside of a border.
## It is like a normal looking around controller you would have in a first person game,
## with the exception that the looking around is only enabled when you are in a [MouseHoverBorder].

## Max degrees for camera rotation in all directions. 
@export var max_degrees: float = 15
@export var rotation_speed: float = 0.05
@export var centering_speed: float = 0.5

@export var enable_feature: bool
@export var enable_at_game_start: bool

## The panel that will allow players
@export_group("Self References")

@export var border_up: Control
@export var border_down: Control

#@onready var border_up := $Camera_Parent_v3/CanvasLayer_ModeChange/Border_Up as Control
#@onready var border_down := $Camera_Parent_v3/CanvasLayer_ModeChange/Border_Down as Control

var is_enabled = false

var original_rotation: Vector3
var min_rotation_x: float
var max_rotation_x: float
var min_rotation_y: float
var max_rotation_y: float

var _delta: float
var _threshold: float = 0.001

var starting_forward
var starting_right
var starting_up

var _is_centering
var _enable_looking = false
var _looking_around_rotation: Vector3

var tempx
var tempy

func _ready():
	tempx = basis.x
	tempy = basis.y
	
	_enable_looking = true
	is_enabled = true
	
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	border_down.mouse_entered.connect(_on_border_down_mouse_entered)
	border_up.mouse_entered.connect(_on_border_up_mouse_entered)
	
	
	var max_radians = deg_to_rad(max_degrees)
	original_rotation = global_rotation		# Local rotation
	_looking_around_rotation = original_rotation
	_looking_around_rotation.x = 0
	min_rotation_x = _looking_around_rotation.x - max_radians
	max_rotation_x = _looking_around_rotation.x + max_radians
	min_rotation_y = _looking_around_rotation.y - max_radians
	max_rotation_y = _looking_around_rotation.y + max_radians
	
	#var tempi = original_rotation
	#tempi.x = -deg_to_rad(30)
	#await temp(tempi)
	#border_up.visible = true
	
	
func _process(delta):
	# Cache the delta: time between this and previous frame.
	_delta = delta	

		
func _input(event):
	if not enable_feature or not is_enabled:
		return
	
	if not event is InputEventMouseMotion or not _enable_looking:
		return
		
	var mouseMotionEvent = event as InputEventMouseMotion
	var mouseDelta = mouseMotionEvent.relative as Vector2
	
	rotate(Vector3.UP, rotation_speed * _delta * -mouseDelta.x)
	rotate_object_local(Vector3.RIGHT, rotation_speed * _delta * -mouseDelta.y)		
	print(global_rotation_degrees)
	#rotation.x = clampf(rotation.x, min_rotation_x, max_rotation_x)
	#rotation.y = clampf(rotation.y, min_rotation_y, max_rotation_y)
		
func enable_looking():
	_enable_looking = true
	
	
func disable_looking():
	_enable_looking = false


func temp(global_euler: Vector3):
	# Linear translation of X and Z
	var tween_rot = create_tween()
	tween_rot.bind_node(self).set_parallel(true)
	var duration = global_euler.distance_to(global_position) / centering_speed
	tween_rot.tween_property(self, "global_rotation:x", global_euler.x, duration)
	tween_rot.tween_property(self, "global_rotation:y", global_euler.y, duration)
	
	await tween_rot.finished
	
		
func _on_border_up_mouse_entered():
	border_up.visible = false
	print("up")
	await temp(Vector3(0, original_rotation.y, original_rotation.z))
	
	border_down.visible = true	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	await Engine.get_main_loop().process_frame
	is_enabled = true
	
	
func _on_border_down_mouse_entered():
	border_down.visible = false
	print("down")
	is_enabled = false	
	await temp(original_rotation)
	border_up.visible = true	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED	
