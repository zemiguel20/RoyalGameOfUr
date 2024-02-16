class_name MaterialChangerUtility
extends HighlightUtility

@export var highlight_material : Material
@export var mesh_to_highlight : GeometryInstance3D
var starting_material : Material

func _ready():
	starting_material = mesh_to_highlight.material_override

# Override Methods
func _highlight():
	mesh_to_highlight.material_override = highlight_material
	
func _dehighlight():
	mesh_to_highlight.material_override = starting_material
	
