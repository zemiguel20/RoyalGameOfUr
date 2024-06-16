class_name SelectionInputReader extends Node
## Reads selection input from an Area3D node.


signal hovered
signal dehovered
signal clicked
signal hold_started
signal hold_stopped

@export var input_detection_area: Area3D
@export_range(0.0, 1.0, 0.025)
var hold_threshold = 0.3 # seconds to determine a hold action

# Variable to track the mouse press time
var mouse_press_time = 0.0
var is_holding = false

var _area_press_detected = false # Used to start counting hold time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_detection_area.mouse_entered.connect(_on_mouse_entered)
	input_detection_area.mouse_exited.connect(_on_mouse_exited)
	input_detection_area.input_event.connect(_on_input_event)


func _process(delta: float) -> void:
	# Check if it is a hold
	if _area_press_detected and Input.is_action_pressed("game_select"):
		var current_time = Time.get_ticks_msec() / 1000.0
		var elapsed_time = current_time - mouse_press_time
		if elapsed_time >= hold_threshold and not is_holding:
			is_holding = true
			hold_started.emit()


func _input(event: InputEvent) -> void:
	if _area_press_detected and event.is_action_released("game_select"):
		_area_press_detected = false
		if is_holding:
			# Mouse was held
			is_holding = false
			hold_stopped.emit()
		else:
			# Mouse was clicked
			clicked.emit()


func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("game_select"):
		# start tracking time
		mouse_press_time = Time.get_ticks_msec() / 1000.0
		_area_press_detected = true


func _on_mouse_entered():
	hovered.emit()


func _on_mouse_exited():
	dehovered.emit()



