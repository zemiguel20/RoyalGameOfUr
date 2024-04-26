extends Node3D

signal roll_finished(value: int)

@onready var _highlighter: MaterialHighlighter = $MaterialHighlighter

const ROTATION_ZERO := Vector3(-30, -120, 115)
const ROTATION_ONE := Vector3.ZERO

func _ready():
	await get_tree().create_timer(0.1).timeout
	global_position -= Vector3.UP * 2 * global_basis.get_scale().y
	

func highlight() -> void:
	if _highlighter != null:
		_highlighter.highlight()


func dehighlight() -> void:
	if _highlighter != null:
		_highlighter.dehighlight()
		

func outline_if_one() -> void:
	pass

		
func roll(random_throwing_position: Vector3, invert_throwing_direction: bool) -> void:
	global_position = random_throwing_position - Vector3.UP * 6 * global_basis.get_scale().y
	var value = randi_range(0, 1)
	basis = Basis.from_euler(General.deg_to_rad(_get_rotation(value)))
	await get_tree().create_timer(0.6).timeout
	roll_finished.emit(value)


func _get_rotation(value) -> Vector3:
	return ROTATION_ZERO if value == 0 else ROTATION_ONE
