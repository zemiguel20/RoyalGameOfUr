class_name PieceDragger
extends Node
## Makes the pieces float and follow the cursor.


const FLOAT_HEIGHT: float = 0.05
const BOUNDS: Vector2 = Vector2(0.2, 0.2)

var _pieces_to_drag: Array[Piece] = []
var _original_positions: Array[Vector3] = []
var _is_dragging: bool = false
var _table: StaticBody3D # Used as the origin and plane for dragging


func _ready() -> void:
	_table = get_tree().get_nodes_in_group("table").front() as StaticBody3D


func start(spot: Spot) -> void:
	if _is_dragging:
		return
	
	_pieces_to_drag = spot.pieces.duplicate()
	
	_original_positions.clear()
	for piece in _pieces_to_drag:
		_original_positions.append(piece.global_position)
	
	_is_dragging = true


func stop() -> void:
	_reset_pieces_positions()
	_pieces_to_drag.clear()
	_is_dragging = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _is_dragging:
		# Get intersection point projection from screen to world
		var cam = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		
		var board_surface_y = _table.global_position.y
		
		var plane = Plane(Vector3.UP, Vector3(0, board_surface_y, 0))
		var result = plane.intersects_ray(cam.project_ray_origin(mouse_pos), \
											cam.project_ray_normal(mouse_pos))
		
		if result != null:
			# Clamp intersection point within bounds around the board
			var result_local = _table.to_local(Vector3(result.x, result.y, result.z))
			result_local.x = clampf(result_local.x, -BOUNDS.x, BOUNDS.x)
			result_local.z = clampf(result_local.z, -BOUNDS.y, BOUNDS.y)
			var clamped_result = _table.to_global(result_local)
			
			# Update dragged pieces position
			for i in _pieces_to_drag.size():
				var piece = _pieces_to_drag[i]
				var target_pos = clamped_result
				target_pos.y += FLOAT_HEIGHT + (i * piece.get_model_height())
				piece.global_position = lerp(piece.global_position, target_pos, 8 * delta)


func _reset_pieces_positions() -> void:
	for i in _pieces_to_drag.size():
		var piece = _pieces_to_drag[i]
		var original_pos = _original_positions[i]
		piece.move_line(original_pos, 0.4)
