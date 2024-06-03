class_name PieceDragger extends Node
## Makes the pieces follow the cursor during selection.


@export var selector: InteractiveGameMoveSelector
@export var float_height: float = 0.05

var is_dragging: bool = false
var pieces_to_drag: Array[Piece] = []
var original_positions: Array[Vector3] = []
var board_surface_y: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selector.from_spot_selected.connect(_on_from_spot_selected)
	selector.selection_canceled.connect(_on_selection_cancel)
	selector.move_selected.connect(_on_move_selected.unbind(1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dragging:
		# Get intersection point projection from screen to world
		var cam = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		var plane = Plane(Vector3.UP, Vector3(0, board_surface_y, 0))
		var result = plane.intersects_ray(cam.project_ray_origin(mouse_pos), cam.project_ray_normal(mouse_pos))
		
		if result != null:
			# Interpolate drag spot position
			var x = clamp(result.x, -1.5, 2.5)
			var z = clamp(result.z, -5, 5)
			for i in pieces_to_drag.size():
				var piece = pieces_to_drag[i]
				var y = board_surface_y + float_height + (i * piece.get_height_scaled())
				var target_pos = Vector3(x,y,z)
				piece.global_position = lerp(piece.global_position, target_pos, 8 * delta)


func _on_from_spot_selected(spot: Spot) -> void:
	pieces_to_drag.assign(spot.pieces)
	
	original_positions.clear()
	for piece in pieces_to_drag:
		original_positions.append(piece.global_position)
	
	board_surface_y = spot.global_position.y
	
	is_dragging = true


func _on_selection_cancel() -> void:
	_reset_pieces_positions()
	pieces_to_drag.clear()
	is_dragging = false


func _on_move_selected() -> void:
	pieces_to_drag.clear()
	is_dragging = false


func _reset_pieces_positions() -> void:
	for i in pieces_to_drag.size():
		var piece = pieces_to_drag[i]
		var original_pos = original_positions[i]
		piece.move_anim.play(original_pos, General.MoveAnim.LINE)
