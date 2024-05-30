@tool
class_name WireArrowMesh extends ArrayMesh


func _init() -> void:
	# Define the vertices of the arrow
	var vertices = PackedVector3Array([
		# Arrowhead vertices
		Vector3(0, 1, 0),          # tip (0)
		Vector3(-0.5, 0, 0.5),     # base front left (1)
		Vector3(0.5, 0, 0.5),      # base front right (2)
		Vector3(0.5, 0, -0.5),     # base back right (3)
		Vector3(-0.5, 0, -0.5),    # base back left (4)

		# Arrow shaft vertices
		Vector3(-0.1, 0, 0.1),     # bottom base front left (5)
		Vector3(0.1, 0, 0.1),      # bottom base front right (6)
		Vector3(0.1, 0, -0.1),     # bottom base back right (7)
		Vector3(-0.1, 0, -0.1),    # bottom base back left (8)
		Vector3(-0.1, -1, 0.1),    # top base front left (9)
		Vector3(0.1, -1, 0.1),     # top base front right (10)
		Vector3(0.1, -1, -0.1),    # top base back right (11)
		Vector3(-0.1, -1, -0.1)    # top base back left (12)
	])

	# Define the indices for the lines
	var indices = PackedInt32Array([
		# Arrowhead lines
		0, 1,
		0, 2,
		0, 3,
		0, 4,
		1, 2,
		2, 3,
		3, 4,
		4, 1,
		
		# Shaft lines
		5, 6,
		6, 7,
		7, 8,
		8, 5,
		5, 9,
		6, 10,
		7, 11,
		8, 12,
		9, 10,
		10, 11,
		11, 12,
		12, 9
	])
	
	# Create arrays for ArrayMesh
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	# Add a surface to the ArrayMesh
	add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
