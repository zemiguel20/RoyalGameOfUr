class_name MaterialHighlighter
extends Node


@export var highlight_material : Material
@export var mesh_to_highlight : GeometryInstance3D


func highlight():
	print("Highlight!")
	mesh_to_highlight.material_overlay = highlight_material
	(mesh_to_highlight.material_overlay as BaseMaterial3D).render_priority = 1


func dehighlight():
	mesh_to_highlight.material_overlay = null
