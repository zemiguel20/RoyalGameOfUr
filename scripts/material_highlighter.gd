class_name MaterialHighlighter
extends Node


@export var highlight_material : Material
@export var mesh_to_highlight : GeometryInstance3D
@export var starting_material : Material


func highlight():
	mesh_to_highlight.material_override = highlight_material


func dehighlight():
	mesh_to_highlight.material_override = starting_material
