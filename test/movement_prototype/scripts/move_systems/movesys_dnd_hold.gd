extends DragDropper


func selection_input_triggered(event):
	return event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT


func confirm_input_triggered(event):
	return event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT
