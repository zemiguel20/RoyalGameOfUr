class_name MouseHoverBorderV2
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
			($"../.." as CameraLookAroundV2).look_left()
		elif direction == BorderDirection.Right:
			($"../.." as CameraLookAroundV2).look_right()	
		elif direction == BorderDirection.Down:
			($"../.." as CameraLookAroundV2).look_down()	
		elif direction == BorderDirection.Up:
			($"../.." as CameraLookAroundV2).look_up()	


func _on_mouse_entered():
	enabled = true


func _on_mouse_exited():
	enabled = false	
	($"../.." as CameraLookAroundV2).start_centre()
