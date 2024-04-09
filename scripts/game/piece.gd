class_name Piece
extends Node3D
## Piece of the game. Has selection and highlighting functionality. Also can be physically moved.


signal clicked(sender: Piece)

enum MOVE_ANIM {ARC, LINE, NONE}

@export var move_arc_height: float = 1.0
@export var move_duration: float = 1.0
@export_enum("One:0", "Two:1") var player: int
@export var material_changer: MaterialHighlighter


## Enables selection and highlighting effects
func highlight():
	material_changer.highlight()


## Disables selection and highlighting effects
func dehighlight():
	material_changer.dehighlight()


func move(to: Vector3, anim: MOVE_ANIM):
	match anim:
		MOVE_ANIM.ARC:
			await _move_arc(to)
		_:
			global_position = to
			await get_tree().create_timer(0.1).timeout


## AI calls this function directly
func on_click():
	clicked.emit(self)


func _on_input_event(_camera, event: InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		on_click()


func _move_arc(target_pos: Vector3):
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
