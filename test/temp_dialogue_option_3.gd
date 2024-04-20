extends Panel

var _active := false


func _process(delta):
	if _active:
		global_position = get_viewport().get_mouse_position() - Vector2.RIGHT * size.x/2
		

func _on_option_3_mouse_entered():
	visible = true
	_active = true


func _on_option_3_mouse_exited():
	visible = false
	_active = false
