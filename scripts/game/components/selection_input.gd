class_name SelectionInputReader extends Area3D
## Area3D specialized in reading selection input.


signal clicked
signal hold_started
signal hold_stopped


## Time threshold to distinguish between a click and holding, in seconds
@export_range(0.0, 1.0, 0.025, "suffix:s") var hold_threshold = 0.3 


var is_holding = false

# Variable to help track the mouse press duration
var _press_timestamp_sec = 0.0

# Flag for when a press is detected
var _is_pressing = false 


# Detects the button press
func _input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		# start tracking time
		_press_timestamp_sec = Time.get_ticks_msec() / 1000.0
		_is_pressing = true


# Counts press time. Compares with threshold to determine if it is holding.
func _process(_delta: float) -> void:
	# Check if it is a hold
	if _is_pressing and Input.is_action_pressed("select"):
		var current_timestamp_sec = Time.get_ticks_msec() / 1000.0
		var elapsed_time_sec = current_timestamp_sec - _press_timestamp_sec
		if elapsed_time_sec >= hold_threshold and not is_holding:
			is_holding = true
			hold_started.emit()


# Detects button release
func _input(event: InputEvent) -> void:
	if _is_pressing and event.is_action_released("select"):
		_is_pressing = false
		
		if is_holding:
			is_holding = false
			hold_stopped.emit()
		else:
			clicked.emit()
