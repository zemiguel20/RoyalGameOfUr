class_name Piece
extends StaticBody3D
## Piece of the game. Has selection and highlighting functionality. Also can be physically moved.


signal clicked(sender: Piece)

@export var move_animation_curve: Curve
@export var move_arc_height: float = 2.0
@export var move_duration: float = 1.5

var _animation_framerate = 60
@onready var material_changer = $MaterialChanger

## Enables selection and highlighting effects
func enable_selection():
	input_ray_pickable = true
	material_changer.highlight()


## Disables selection and highlighting effects
func disable_selection():
	input_ray_pickable = false
	material_changer.dehighlight()


## Coroutine that moves the piece physically along the given [param movement_path].
func move(movement_path: Array[Vector3]):
	# TODO: implement
	for pos in movement_path:
		await _move_arc(pos)


func _on_input_event(camera, event: InputEvent, position, normal, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		clicked.emit(self)


func _move_arc(target_pos : Vector3):
	var old_pos = position
	var global_arc_heigth = move_arc_height + old_pos.y
	var t = 0
	var frame_duration = 1.0 / _animation_framerate
	while (t < move_duration):
		var progress = t / move_duration
		position.x = lerpf(old_pos.x, target_pos.x, progress)
		position.z = lerpf(old_pos.z, target_pos.z, progress)
		# Handle the y-axis independentely
		position.y = lerpf(old_pos.y, move_arc_height, move_animation_curve.sample(progress))
		t += frame_duration
		await get_tree().create_timer(frame_duration).timeout
