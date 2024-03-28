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


func _on_mouse_entered():
	print("Enabled Looking")
	($"../.." as CameraLookAroundV2).enable_looking()


func _on_mouse_exited():
	print("Disabled Looking")
	($"../.." as CameraLookAroundV2).disable_looking()
	($"../.." as CameraLookAroundV2).start_centre()
	
