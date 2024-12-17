class_name DiceZone
extends Node3D
## Container of points where the dice can be placed and thrown from.


@onready var _dice_placing_spots: Node3D = $DicePlacingSpots
@onready var _dice_throw_spots: Node3D = $DiceThrowSpots


func get_placing_points_global_randomized() -> Array[Vector3]:
	var spots = _dice_placing_spots.get_children()
	var points: Array[Vector3] = []
	points.assign(spots.map(func(spot: Node3D): return spot.global_position))
	points.shuffle()
	return points
