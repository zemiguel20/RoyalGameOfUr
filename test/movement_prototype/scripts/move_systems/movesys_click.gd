extends MoveSystem


func full_input_triggered(event):
	return event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT


func execute_move():
	var target_tile_found = false
	if _selected_pieces.size() > 0:
		var tile = _tiles[randi_range(0, _tiles.size()-1)]
		
		if tile != _source_tile and tile.register_pieces_direct(_selected_pieces):
			_source_tile.remove_pieces()
			target_tile_found = true
		
		if !target_tile_found:
			_source_tile.anim_return_pieces()
		
		_selected_pieces.clear()
