class_name MouseHoverBorder
extends ColorRect

enum BorderDirection 
{
	Left = 0,
	Right = 1,
	Down = 2,
	Up = 3
}

@export var direction: BorderDirection

var enabled

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(delta):
	if enabled:
		if direction == BorderDirection.Left:
			($"../.." as CameraLookAround).look_left()
		elif direction == BorderDirection.Right:
			($"../.." as CameraLookAround).look_right()	
		elif direction == BorderDirection.Down:
			($"../.." as CameraLookAround).look_down()	
		elif direction == BorderDirection.Up:
			($"../.." as CameraLookAround).look_up()	


func _on_mouse_entered():
	enabled = true


func _on_mouse_exited():
	enabled = false	
	($"../.." as CameraLookAround).start_centre()
