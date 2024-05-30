@tool
class_name CubeMeshMarkerAddon extends MeshInstance3D
## Draws a cube mesh around the parent marker.


@export var color: Color = Color.TEAL:
	set(new_color):
		color = new_color
		_create_box_new_mesh()

var parent: Marker3D
var old_gizmo_size = 0.0 # for optimization: check if dirty


func _ready() -> void:
	# DELETE ITSELF IF RUNNING IN GAME
	if not Engine.is_editor_hint():
		queue_free()


func _physics_process(_delta):
	if Engine.is_editor_hint():
		parent = get_parent_node_3d()
		update_configuration_warnings()
		
		if parent is Marker3D and parent.gizmo_extents != old_gizmo_size:
			_create_box_new_mesh()
			old_gizmo_size = parent.gizmo_extents
		
		position = Vector3.ZERO # Force follow parent marker


func _create_box_new_mesh():
	if not parent is Marker3D:
		return
	
	var size = parent.gizmo_extents
	
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material_override = mat
	
	mesh = ImmediateMesh.new()
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(color)
	
	# BOTTOM BASE
	mesh.surface_add_vertex(Vector3(size, -size, size))
	mesh.surface_add_vertex(Vector3(size, -size, -size))
	mesh.surface_add_vertex(Vector3(size, -size, -size))
	mesh.surface_add_vertex(Vector3(-size, -size, -size))
	mesh.surface_add_vertex(Vector3(-size, -size, -size))
	mesh.surface_add_vertex(Vector3(-size, -size, size))
	mesh.surface_add_vertex(Vector3(-size, -size, size))
	mesh.surface_add_vertex(Vector3(size, -size, size))
	
	# UPPER BASE
	mesh.surface_add_vertex(Vector3(size, size, size))
	mesh.surface_add_vertex(Vector3(size, size, -size))
	mesh.surface_add_vertex(Vector3(size, size, -size))
	mesh.surface_add_vertex(Vector3(-size, size, -size))
	mesh.surface_add_vertex(Vector3(-size, size, -size))
	mesh.surface_add_vertex(Vector3(-size, size, size))
	mesh.surface_add_vertex(Vector3(-size, size, size))
	mesh.surface_add_vertex(Vector3(size, size, size))
	
	# SIDES
	mesh.surface_add_vertex(Vector3(size, -size, size))
	mesh.surface_add_vertex(Vector3(size, size, size))
	mesh.surface_add_vertex(Vector3(size, -size, -size))
	mesh.surface_add_vertex(Vector3(size, size, -size))
	mesh.surface_add_vertex(Vector3(-size, -size, -size))
	mesh.surface_add_vertex(Vector3(-size, size, -size))
	mesh.surface_add_vertex(Vector3(-size, -size, size))
	mesh.surface_add_vertex(Vector3(-size, size, size))
	
	mesh.surface_end()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not parent or not parent is Marker3D:
		warnings.append("Needs to have a Marker3D node as a parent.")
	return warnings
