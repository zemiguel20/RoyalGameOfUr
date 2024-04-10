class_name Piece
extends Node3D
## Piece of the game. Has selection and highlighting functionality. Also can be physically moved.


signal clicked(sender: Piece)

enum MOVE_ANIM {ARC, LINE, NONE}

const MOVE_ARC_HEIGHT: float = 1.0
const MOVE_DURATION: float = 0.4

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
		MOVE_ANIM.LINE:
			await _move_line(to)
		_:
			global_position = to
			await get_tree().create_timer(MOVE_DURATION).timeout


func _move_arc(target_pos: Vector3):
	# Linear translation of X and Z
	var tween_xz = create_tween()
	tween_xz.bind_node(self).set_parallel(true)
	tween_xz.tween_property(self, "global_position:x", target_pos.x, MOVE_DURATION)
	tween_xz.tween_property(self, "global_position:z", target_pos.z, MOVE_DURATION)
	
	# Arc translation of Y
	var high_point = maxf(global_position.y, target_pos.y) + MOVE_ARC_HEIGHT
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(self, "global_position:y", high_point, MOVE_DURATION * 0.5).set_ease(Tween.EASE_OUT)
	tween_y.tween_property(self, "global_position:y", target_pos.y, MOVE_DURATION * 0.5).set_ease(Tween.EASE_IN)
	
	# Tweens run at same time, so only wait for one of them
	await tween_xz.finished


func _move_line(target_pos: Vector3):
	var tween = create_tween().bind_node(self)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, MOVE_DURATION)
	await tween.finished
