class_name DragDropper
extends MoveSystem

@export var _board_surface_y: float = 0.35


func _process(delta):
	_update_dragged_pieces()


func _update_dragged_pieces():
	if _selected_pieces.size() == 0: return
	
	if _selected_pieces[0].is_following_mouse:
		var cam = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		
		var plane = Plane(Vector3.UP, Vector3(0, _board_surface_y, 0))
		var result = plane.intersects_ray(cam.project_ray_origin(mouse_pos), cam.project_ray_normal(mouse_pos))
		
		if result != null:
			for piece in _selected_pieces:
				var x = clamp(result.x, -1.5, 2.5)
				var z = clamp(result.z, -5, 5)
				piece.target_pos = Vector3(x, piece.global_position.y, z)


func execute_move():
	var target_tile_found = false
	if _selected_pieces.size() > 0:
		for tile in _tiles:
			if tile != _source_tile and tile.try_register_pieces(_selected_pieces):
				_source_tile.remove_pieces()
				target_tile_found = true
		
		if !target_tile_found:
			_source_tile.anim_return_pieces()
		
		_selected_pieces.clear()
