@tool
class_name MaterialHighlighterComponent extends Node
## Applies a highlight material to a target mesh as an overlay. Can be turned on or off.


@export var highlight_material: Material

@export var highlight_color: Color = Color.WHITE:
	set(new_value):
		highlight_color = new_value
		_update_color()

@export var meshes_to_highlight: Array[GeometryInstance3D]:
	set(new_instance):
		# Reset current meshes before updating list
		_update_highlight(false)
		meshes_to_highlight = new_instance
		_update_highlight()

@export var active: bool = false:
	set(new_value):
		active = new_value
		_update_highlight()


func _update_highlight(turn_on: bool = active):
	if !meshes_to_highlight:
		return
	
	for mesh in meshes_to_highlight:
		if mesh != null:
			mesh.material_overlay = highlight_material if turn_on else null


# Recursive update of material color
func _update_color(mat: Material = highlight_material):
	if !mat:
		return
	
	if mat is ShaderMaterial:
		mat.set_shader_parameter("color", highlight_color)
	if mat is StandardMaterial3D:
		mat.albedo_color = highlight_color
	
	_update_color(mat.next_pass)
