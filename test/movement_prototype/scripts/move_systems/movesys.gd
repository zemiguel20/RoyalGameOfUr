class_name MoveSystem
extends Node

@export var _tileParent: Node3D

var _tiles: Array[_Tile]
var _source_tile: _Tile
var _selected_pieces: Array[_Piece]
var _is_detecting_input: bool


func _ready():
	for tile in _tileParent.get_children():
		_tiles.append(tile)


func start_selection():
	_is_detecting_input = true


func end_selection():
	_is_detecting_input = false


func _input(event):
	if !_is_detecting_input or not event is InputEventMouseButton: return
	
	if full_input_triggered(event):
		select_pieces()
		execute_move()
	elif selection_input_triggered(event) and _selected_pieces.size() == 0:
		select_pieces()
	elif confirm_input_triggered(event):
		execute_move()
	elif cancel_input_triggered(event):
		cancel_move()


func full_input_triggered(event) -> bool:
	return false


func selection_input_triggered(event) -> bool:
	return false


func confirm_input_triggered(event) -> bool:
	return false


func cancel_input_triggered(event) -> bool:
	return event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT


func select_pieces():
	for tile in _tiles:
		if tile.anim_try_lift_pieces():
			_selected_pieces = tile.get_pieces_to_drag().duplicate()
			_source_tile = tile


func execute_move():
	pass


func cancel_move():
	if _selected_pieces.size() > 0:
		_source_tile.anim_return_pieces()
		_selected_pieces.clear()
