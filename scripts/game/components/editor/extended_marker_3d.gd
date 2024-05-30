@tool
class_name ExtendedMarker3D extends Marker3D
## Marker3D with higher precision on the gizmo size.


@export_range(0.0, 1.0, 0.001, "or_greater") var gizmo_extends_override: float:
	set(new_value):
		gizmo_extends_override = new_value
		gizmo_extents = new_value
