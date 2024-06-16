class_name GameCamera extends Camera3D
## Camera that interpolates between multiple POVs depending on game events.
## During gameplay, can use mouse dragging to look around.


@export var pov_start: Node3D
@export var pov_intro: Node3D
@export var pov_singleplayer: Node3D
@export var pov_hotseat: Node3D

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

var can_look_around := false
var press_detected := false # Used to start counting hold time
var press_time := 0.0 # Variable to track the press time
var is_looking_around := false
var look_around_offset_rotation := Vector2.ZERO
var look_around_anchor_rotation := Vector3.ZERO
#endregion


func _ready():
	global_transform = pov_start.global_transform
	
	GameEvents.play_pressed.connect(_on_play_pressed)
	GameEvents.opponent_seated.connect(_on_opponent_seated)
	GameEvents.game_started.connect(_on_game_started)
	GameEvents.game_ended.connect(_on_game_ended)
	GameEvents.back_to_main_menu_pressed.connect(_on_back_to_main_menu)


#region Look Around logic
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("look_around") and can_look_around:
		# start tracking time
		press_time = Time.get_ticks_msec() / 1000.0
		press_detected = true
		
	elif event.is_action_released("look_around") and is_looking_around:
		_stop_look_around()
		
	elif is_looking_around and event is InputEventMouseMotion:
		# Read mouse input
		var drag_event = event as InputEventMouseMotion
		var mouse_delta = drag_event.relative
		_update_look_around(mouse_delta)


func _process(_delta) -> void:
	# Count press time to check if holding
	if press_detected and Input.is_action_pressed("look_around"):
		var current_time = Time.get_ticks_msec() / 1000.0
		var elapsed_time = current_time - press_time
		if elapsed_time >= hold_threshold and not is_looking_around:
			_start_look_around()


func _start_look_around() -> void:
	is_looking_around = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	look_around_anchor_rotation = rotation
	look_around_offset_rotation = Vector2.ZERO
	GameEvents.camera_look_around_started.emit()


func _stop_look_around() -> void:
	is_looking_around = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_tween_to_pov(pov_singleplayer)
	GameEvents.camera_look_around_stopped.emit()


func _update_look_around(mouse_delta: Vector2) -> void:
	# NOTE: DOWN IS POSITIVE, 2D Y axis is inverted
	look_around_offset_rotation += mouse_delta * (looking_sensitivity * 0.001)
	print(mouse_delta)
	# Limit lookaround
	look_around_offset_rotation.x = \
		clampf(look_around_offset_rotation.x, -max_angle_left, max_angle_right)
	look_around_offset_rotation.y = \
		clampf(look_around_offset_rotation.y, -max_angle_up, max_angle_down)
	
	# Set anchor point and then apply offset
	rotation = look_around_anchor_rotation
	rotate(Vector3.DOWN, look_around_offset_rotation.x) # Horizontal
	rotate_object_local(Vector3.LEFT, look_around_offset_rotation.y) # Vertical
#endregion


func _on_play_pressed() -> void:
	if GameManager.is_rematch:
		return
	
	var target_pov: Node3D
	if GameManager.is_hotseat:
		target_pov = pov_hotseat
	else:
		target_pov = pov_intro
	
	_tween_to_pov(target_pov)


func _on_opponent_seated() -> void:
	_tween_to_pov(pov_singleplayer)


func _on_back_to_main_menu() -> void:
	_tween_to_pov(pov_start)


func _on_game_started() -> void:
	if not GameManager.is_hotseat:
		can_look_around = true


func _on_game_ended() -> void:
	can_look_around = false


func _tween_to_pov(target_pov: Node3D) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_transform", target_pov.global_transform, transition_duration)
