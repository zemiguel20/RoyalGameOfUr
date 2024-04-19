class_name MaterialHighlighter
extends Node


@export var highlight_material : Material
@export var mesh_to_highlight : GeometryInstance3D


func highlight():
	mesh_to_highlight.material_overlay = highlight_material


func dehighlight():
	mesh_to_highlight.material_overlay = null
