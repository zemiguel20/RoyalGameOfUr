@tool
class_name WireCubeMesh extends ArrayMesh


func _init() -> void:
	# Define the vertices of the box
	var vertices = PackedVector3Array([
		Vector3(-1, -1, -1), # bottom back left (0)
		Vector3(1, -1, -1),  # bottom back right (1)
		Vector3(1, 1, -1),   # bottom front right (2)
		Vector3(-1, 1, -1),  # bottom front left (3)
		Vector3(-1, -1, 1),  # top back left (4)
		Vector3(1, -1, 1),   # top back right (5)
		Vector3(1, 1, 1),    # top front right (6)
		Vector3(-1, 1, 1)    # top front left (7)
	])

	# Define the indices for the lines
	var indices = PackedInt32Array([
		# Bottom square
		0, 1,
		1, 2,
		2, 3,
		3, 0,

		# Top square
		4, 5,
		5, 6,
		6, 7,
		7, 4,

		# Vertical edges
		0, 4,
		1, 5,
		2, 6,
		3, 7
	])
	
	# Create arrays for ArrayMesh
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	# Add a surface to the ArrayMesh
	add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
