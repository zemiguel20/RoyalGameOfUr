class_name MeshHighlighter extends Node
## Highlights a target meshe by applying a special material as overlay.


@export var material: Material

@export var target: MeshInstance3D


func set_active(active: bool) -> MeshHighlighter:
	if target != null:
		target.material_overlay = material if active else null
	return self


func set_material_color(color: Color) -> MeshHighlighter:
	_update_color(material, color)
	return self


# Recursive update of material color and all its next passes
func _update_color(mat: Material, color: Color):
	if !mat:
		return
	
	if mat is ShaderMaterial:
		mat.set_shader_parameter("color", color)
	if mat is StandardMaterial3D:
		mat.albedo_color = color
	
	_update_color(mat.next_pass, color)
