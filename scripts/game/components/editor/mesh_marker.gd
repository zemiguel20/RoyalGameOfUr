@tool
class_name MeshMarkerAddon extends MeshInstance3D
## Adds a mesh to the parent marker.


@export var color: Color = Color.TEAL:
	set(new_color):
		color = new_color
		_update_material()

var parent: Marker3D


func _ready() -> void:
	# DELETE ITSELF IF RUNNING IN GAME
	if not Engine.is_editor_hint():
		queue_free()
	else:
		_update_material()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not parent or not parent is Marker3D:
		warnings.append("Needs to have a Marker3D node as a parent.")
	return warnings


func _physics_process(_delta):
	parent = get_parent_node_3d()
	update_configuration_warnings()
	
	if parent is Marker3D:
		scale = Vector3(parent.gizmo_extents, parent.gizmo_extents, parent.gizmo_extents)


func _update_material():
	if not material_override:
		var mat = StandardMaterial3D.new()
		mat.vertex_color_use_as_albedo = true
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material_override = mat
	
	material_override.albedo_color = color
