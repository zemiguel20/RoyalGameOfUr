class_name DiceSpot
extends Node3D

@export var throwing_velocity_multiplier: float = 1.0

func get_direction():
	return global_basis.z.normalized()