class_name DieTip
extends Node3D

@export_range(0, 1) var value: int

# NOTE: uses Y axis as direction
func angle_to_up() -> float:
	return global_basis.y.angle_to(Vector3.UP)
