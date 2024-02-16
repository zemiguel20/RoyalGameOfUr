extends MovingUtility

func _on_area_3d_input_event(camera, event : InputEvent, position, normal, shape_idx):
	if (event is InputEventMouseButton and event.is_pressed()):
		MoveToTargetPosition(self.position + Vector3.FORWARD * -1)
