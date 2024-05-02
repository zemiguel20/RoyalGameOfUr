@tool
class_name MaterialHighlighterComponent
extends Node
## Applies a highlight material to a target mesh as an overlay. Can be turned on or off.


@export var highlight_material : Material

@export var highlight_color : Color = Color.WHITE:
	set(new_value):
		highlight_color = new_value
		_update_color(highlight_material)

@export var mesh_to_highlight : GeometryInstance3D:
	set(new_instance):
		# Reset current mesh before updating to new one
		if mesh_to_highlight:
			mesh_to_highlight.material_overlay = null
		mesh_to_highlight = new_instance
		_update_highlight()

@export var active : bool = false:
	set(new_value):
		active = new_value
		_update_highlight()


func _update_highlight():
	if !mesh_to_highlight:
		return
	mesh_to_highlight.material_overlay = highlight_material if active else null


# Recursive update of material color
func _update_color(mat: Material):
	if !mat:
		return
	
	if mat is ShaderMaterial:
		mat.set_shader_parameter("color", highlight_color)
	
	_update_color(mat.next_pass)
