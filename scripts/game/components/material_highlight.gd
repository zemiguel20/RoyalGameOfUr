@tool
class_name MaterialHighlight extends Node
## Applies a highlight material to a target mesh as an overlay. Can be turned on or off.


@export var material: Material

@export var color: Color = Color.WHITE:
	set(new_value):
		color = new_value
		_update_color()

@export var target_meshes: Array[GeometryInstance3D]:
	set(new_instance):
		# Reset current meshes before updating list
		_update_highlight_state(false)
		target_meshes = new_instance
		_update_highlight_state(active)

@export var active: bool = false:
	set(new_value):
		active = new_value
		_update_highlight_state(active)


@warning_ignore("shadowed_variable")
func _update_highlight_state(active: bool):
	if !target_meshes:
		return
	
	for mesh in target_meshes:
		if mesh != null:
			mesh.material_overlay = material if active else null


# Recursive update of material color
func _update_color(mat: Material = material):
	if !mat:
		return
	
	if mat is ShaderMaterial:
		mat.set_shader_parameter("color", color)
	if mat is StandardMaterial3D:
		mat.albedo_color = color
	
	_update_color(mat.next_pass)
