class_name Piece
extends StaticBody3D
## Piece of the game. Has selection and highlighting functionality. Also can be physically moved.


signal clicked(sender: Piece)

@export var move_arc_height: float = 1.0
@export var move_duration: float = 1.0
@export var player: General.PlayerID

@onready var material_changer = $MaterialChanger


## Enables selection and highlighting effects
func enable_selection():
	input_ray_pickable = true
	material_changer.highlight()


## Disables selection and highlighting effects
func disable_selection():
	input_ray_pickable = false
	material_changer.dehighlight()


## Coroutine that moves the piece physically along the given [param movement_path].  [param movement_path] contains global positions.
func move(movement_path: Array[Vector3]):
	for pos in movement_path:
		await _move_arc(pos)


func _on_input_event(_camera, event: InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		clicked.emit(self)


func _move_arc(target_pos : Vector3):
	# Linear translation of X and Z
	var tween_xz = create_tween()
	tween_xz.bind_node(self).set_parallel(true)
	tween_xz.tween_property(self, "global_position:x", target_pos.x, move_duration)
	tween_xz.tween_property(self, "global_position:z", target_pos.z, move_duration)
	
	# Arc translation of Y
	var high_point = maxf(global_position.y, target_pos.y) + move_arc_height
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(self, "global_position:y", high_point, move_duration * 0.5).set_ease(Tween.EASE_OUT)
	tween_y.tween_property(self, "global_position:y", target_pos.y, move_duration * 0.5).set_ease(Tween.EASE_IN)
	
	# Tweens run at same time, so only wait for one of them
	await tween_xz.finished
