class_name _Piece
extends Node

const MOVE_ARC_HEIGHT = 1.0
const MOVE_DURATION = 0.5

@export var height: float = 0.15

var _index = 0
var target_pos: Vector3
var is_following_mouse = false


func set_index(index: int):
	_index = index


func _process(delta):
	if is_following_mouse:
		var tween_x = create_tween().set_trans(Tween.TRANS_CUBIC)
		var tween_z = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween_x.tween_property(self, "global_position:x", target_pos.x, MOVE_DURATION * 0.1).set_ease(Tween.EASE_IN)
		tween_z.tween_property(self, "global_position:z", target_pos.z, MOVE_DURATION * 0.1).set_ease(Tween.EASE_IN)


func anim_lift(tile: _Tile):
	var high_point = min(self.global_position.y + MOVE_ARC_HEIGHT, tile.height + ((_index + 1) * self.height)) + 1
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(self, "global_position:y", high_point, MOVE_DURATION * 0.5).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.05).timeout
	is_following_mouse = true


func anim_drop(tile: _Tile):
	is_following_mouse = false
	
	var tween_x = create_tween().set_trans(Tween.TRANS_CUBIC)
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	var tween_z = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_x.tween_property(self, "global_position:x", tile.global_position.x, MOVE_DURATION * 0.5).set_ease(Tween.EASE_IN)
	tween_y.tween_property(self, "global_position:y", tile.global_position.y + tile.height + (_index * self.height), MOVE_DURATION * 0.5).set_ease(Tween.EASE_IN)
	tween_z.tween_property(self, "global_position:z", tile.global_position.z, MOVE_DURATION * 0.5).set_ease(Tween.EASE_IN)


func anim_arc(tile: _Tile):
	is_following_mouse = false
	target_pos = Vector3(tile.global_position.x, tile.global_position.y + tile.height + (_index * self.height), tile.global_position.z)
	
	# Linear translation of X and Z
	var tween_xz = create_tween()
	tween_xz.bind_node(self).set_parallel(true)
	tween_xz.tween_property(self, "global_position:x", target_pos.x, MOVE_DURATION)
	tween_xz.tween_property(self, "global_position:z", target_pos.z, MOVE_DURATION)
	
	# Arc translation of Y
	var high_point = maxf(self.global_position.y, target_pos.y) + MOVE_ARC_HEIGHT
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(self, "global_position:y", high_point, MOVE_DURATION * 0.5).set_ease(Tween.EASE_OUT)
	tween_y.tween_property(self, "global_position:y", target_pos.y, MOVE_DURATION * 0.5).set_ease(Tween.EASE_IN)
	
	# Tweens run at same time, so only wait for one of them
	await tween_xz.finished
