class_name Piece
extends MovingUtility

@export var material_changer : MaterialChangerUtility

@export var move_animation_height_curve : Curve
@export var move_arc_height : float = 2.0
@export var moving_duration : float = 1.5

signal clicked(sender: Piece)

func enable_highlight():
	material_changer.highlight()

func disable_highlight():
	material_changer.dehighlight()

func move(target_position : Vector3):
	move_to_target_position_in_seconds_with_arc(
		target_position, 
		move_arc_height, 
		move_animation_height_curve, 
		moving_duration)

func _on_area_3d_input_event(_camera, event : InputEvent, _position, _normal, _shape_idx):
	if (event is InputEventMouseButton and event.is_pressed()):
		clicked.emit(self)
		
		# For testing purposes
		move(global_position + Vector3.FORWARD * randf_range(-3, -1))
