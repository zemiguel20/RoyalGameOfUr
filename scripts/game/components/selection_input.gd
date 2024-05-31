class_name SelectionInputReader extends Node


signal hovered
signal dehovered
signal selected 

@export var input_detection_area: Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	input_detection_area.mouse_entered.connect(_on_mouse_entered)
	input_detection_area.mouse_exited.connect(_on_mouse_exited)
	input_detection_area.input_event.connect(_on_input_event)


func _on_mouse_entered():
	hovered.emit()


func _on_mouse_exited():
	dehovered.emit()


func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	if event.is_action_pressed("game_select"):
		selected.emit()
