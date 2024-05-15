class_name MaterialHighlighter
extends Node


@export var highlight_material : Material
@export var mesh_to_highlight : GeometryInstance3D

var _initial_mat_override

func _ready():
	_initial_mat_override = mesh_to_highlight.material_override
	

func highlight():
	## Temporarily changed it back to override so the pieces and dice are highlighted.
	mesh_to_highlight.material_override = highlight_material


func dehighlight():
	## Temporarily changed it back to override so the pieces and dice are highlighted.
	mesh_to_highlight.material_override = _initial_mat_override
