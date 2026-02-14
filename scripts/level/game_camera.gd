class_name GameCamera
extends Camera3D
## Camera that interpolates between multiple POVs.
## During gameplay, can use mouse dragging to look around.


@export_range(0.0, 1.0, 0.1, "or_greater", "suffix: s")
var transition_duration: float


#region Look Around variables
@export_range(0.0, 90.0, 0.01, "radians_as_degrees")
var max_angle_up: float = PI / 6
@export_range(0.0, 90.0, 0.01, "radians_as_degrees")
var max_angle_down: float = PI / 6
@export_range(0.0, 90.0, 0.01, "radians_as_degrees")
var max_angle_left: float = PI / 6
@export_range(0.0, 90.0, 0.01, "radians_as_degrees")
var max_angle_right: float = PI / 6

@export_range(0.0, 10.0, 0.1)
var looking_sensitivity: float = 1.0
@export_range(0.0, 1.0, 0.025)
var hold_threshold := 0.2 # seconds to determine a hold action

var can_look_around := false ## Use to enable or disasable looking around

var _press_detected := false # Used to start counting hold time
var _press_time := 0.0 # Variable to track the press time
var _is_looking_around := false
var _look_around_offset_rotation := Vector2.ZERO
var _look_around_anchor_rotation := Vector3.ZERO
#endregion

var _current_pov: Transform3D


## NOTE: [param pov] should be a global transform
func move_to_POV(pov: Transform3D) -> void:
	_current_pov = pov
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_transform", pov, transition_duration)


#region Look Around logic
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("look_around") and can_look_around:
		# start tracking time
		_press_time = Time.get_ticks_msec() / 1000.0
		_press_detected = true
		
	elif event.is_action_released("look_around") and _is_looking_around:
		_stop_look_around()
		
	elif _is_looking_around and event is InputEventMouseMotion:
		# Read mouse input
		var drag_event = event as InputEventMouseMotion
		var mouse_delta = drag_event.relative
		_update_look_around(mouse_delta)


func _process(_delta) -> void:
	# Count press time to check if holding
	if _press_detected and Input.is_action_pressed("look_around"):
		var current_time = Time.get_ticks_msec() / 1000.0
		var elapsed_time = current_time - _press_time
		if elapsed_time >= hold_threshold and not _is_looking_around:
			_start_look_around()


func _start_look_around() -> void:
	_is_looking_around = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_look_around_anchor_rotation = rotation
	_look_around_offset_rotation = Vector2.ZERO


func _stop_look_around() -> void:
	_is_looking_around = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	move_to_POV(_current_pov)


func _update_look_around(mouse_delta: Vector2) -> void:
	# NOTE: DOWN IS POSITIVE, 2D Y axis is inverted
	_look_around_offset_rotation += mouse_delta * (looking_sensitivity * 0.001)
	print(mouse_delta)
	# Limit lookaround
	_look_around_offset_rotation.x = \
		clampf(_look_around_offset_rotation.x, -max_angle_left, max_angle_right)
	_look_around_offset_rotation.y = \
		clampf(_look_around_offset_rotation.y, -max_angle_up, max_angle_down)
	
	# Set anchor point and then apply offset
	rotation = _look_around_anchor_rotation
	rotate(Vector3.DOWN, _look_around_offset_rotation.x) # Horizontal
	rotate_object_local(Vector3.LEFT, _look_around_offset_rotation.y) # Vertical
#endregion
