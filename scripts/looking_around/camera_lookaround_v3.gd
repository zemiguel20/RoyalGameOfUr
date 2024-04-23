class_name CameraLookAroundV3
extends Camera3D

## Big TODO: Fix all names!!

## Max degrees for camera rotation in all directions. 
@export var max_degrees: float = 30
@export var rotation_speed: float = 0.05
@export var centering_speed: float = 0.5
@export var offset_rotation_x: float = -30
@export var degrees_down_to_trigger: float = 15

@export var enable_feature: bool
@export var enable_at_game_start: bool

@export_group("Self References")
@export var border_up: Control

var is_enabled = false

var original_rotation: Vector3
var min_rotation_x: float
var max_rotation_x: float
var min_rotation_y: float
var max_rotation_y: float
var _looking_around_rotation: Vector3
var _board_look_rotation 

var _delta: float
var _enable_looking = false


func _ready():
	_enable_looking = true
	is_enabled = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	border_up.mouse_entered.connect(_on_border_up_mouse_entered)
	
	var max_radians = deg_to_rad(max_degrees)
	original_rotation = global_rotation		# Local rotation
	_looking_around_rotation = original_rotation
	_looking_around_rotation.x = 0
	min_rotation_x = _looking_around_rotation.x - max_radians
	max_rotation_x = _looking_around_rotation.x + max_radians
	min_rotation_y = _looking_around_rotation.y - max_radians
	max_rotation_y = _looking_around_rotation.y + max_radians
	
	_board_look_rotation = global_rotation
	_board_look_rotation.x = deg_to_rad(offset_rotation_x)
	await get_tree().create_timer(.5).timeout
	await temp(_board_look_rotation)
	border_up.visible = true
	
	
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
	rotation.x = clampf(rotation.x, min_rotation_x, max_rotation_x)
	rotation.y = clampf(rotation.y, min_rotation_y, max_rotation_y)
	
	if rotation.x - original_rotation.x < -deg_to_rad(degrees_down_to_trigger):
		_return_to_board()
		
		
func enable_looking():
	_enable_looking = true
	
	
func disable_looking():
	_enable_looking = false


func temp(target_global_euler: Vector3):
	var duration = target_global_euler.distance_to(global_rotation) / centering_speed
	
	# Linear translation of X and Z
	var tween_rot = create_tween()
	tween_rot.bind_node(self).set_parallel(true)
	tween_rot.tween_property(self, "global_rotation:x", target_global_euler.x, duration)
	tween_rot.tween_property(self, "global_rotation:y", target_global_euler.y, duration)
	
	await tween_rot.finished
	
		
func _return_to_board():
	is_enabled = false	
	await temp(_board_look_rotation)
	border_up.visible = true	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED	


func _on_border_up_mouse_entered():
	border_up.visible = false
	await temp(original_rotation)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await Engine.get_main_loop().process_frame
	is_enabled = true
