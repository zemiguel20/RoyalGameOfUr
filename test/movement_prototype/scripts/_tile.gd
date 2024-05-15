class_name _Tile
extends Node

signal mouse_pressed
signal mouse_released

@export_group("References")
@export var _pieces: Array[_Piece]
@export var _mesh: CSGMesh3D
@export var _mat_default: Material
@export var _mat_highlight: Material
@export_group("Tile properties")
@export var height: float = 0.1
@export var _max_pieces_dragged: int = 7

var _is_mouse_in_area = false


func get_pieces_to_drag() -> Array[_Piece]:
	return _pieces.slice(clamp(_pieces.size() - _max_pieces_dragged, 0, 7), _pieces.size())


func remove_pieces():
	_pieces = _pieces.slice(0, _pieces.size() - _max_pieces_dragged)


func anim_try_lift_pieces() -> bool:
	if !_is_mouse_in_area: return false
	
	if _pieces.size() > 0:
		for piece in get_pieces_to_drag():
			piece.anim_lift(self)
	
	return true


func anim_return_pieces():
	for i in _pieces.size():
		_pieces[i].set_index(i)
		_pieces[i].anim_drop(self)


func register_pieces_direct(new_pieces: Array[_Piece]) -> bool:
	for i in new_pieces.size():
		var appended_index = i + _pieces.size()
		new_pieces[i].set_index(appended_index)
		new_pieces[i].anim_arc(self)
	
	_pieces.append_array(new_pieces)
	return true


func try_register_pieces(new_pieces: Array[_Piece]) -> bool:
	if _is_mouse_in_area:
		return _register_pieces(new_pieces)
	else:
		return false


func _register_pieces(new_pieces: Array[_Piece]) -> bool:
	for i in new_pieces.size():
		var appended_index = i + _pieces.size()
		new_pieces[i].set_index(appended_index)
		new_pieces[i].anim_drop(self)
	
	_pieces.append_array(new_pieces)
	return true


func _on_tile_area_mouse_entered():
	_is_mouse_in_area = true
	_mesh.material = _mat_highlight


func _on_tile_area_mouse_exited():
	_is_mouse_in_area = false
	_mesh.material = _mat_default
