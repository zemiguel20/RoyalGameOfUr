class_name DiceZone
extends Node3D
## Container of points where the dice can be placed and thrown from.
## Can also be used to spawn the dice in the placing points during game initialization.


const DIE_PREFAB: PackedScene = preload("res://scenes/game/entities/d4_die.tscn")

@onready var _dice_placing_spots: Node3D = $DicePlacingSpots
@onready var _dice_throw_spots: Node3D = $DiceThrowSpots


func spawn_dice(num_dice: int) -> Array[Die]:
	var dice: Array[Die] = []
	
	var spawn_points = get_placing_points_global_randomized()
	for i in num_dice:
		var die = DIE_PREFAB.instantiate()
		add_child(die)
		dice.append(die)
		die.global_position = spawn_points[i]
	
	return dice


func get_placing_points_global_randomized() -> Array[Vector3]:
	var spots = _dice_placing_spots.get_children()
	var points: Array[Vector3] = []
	points.assign(spots.map(func(spot: Node3D): return spot.global_position))
	points.shuffle()
	return points


func get_throw_points_shuffled() -> Array[ThrowPoint]:
	var spots = _dice_throw_spots.get_children()
	var points: Array[ThrowPoint] = []
	points.assign(spots.map(func(spot: Node3D): return ThrowPoint.from(spot)))
	points.shuffle()
	return points


class ThrowPoint:
	var global_position: Vector3
	var direction: Vector3
	
	static func from(spot: Node3D) -> ThrowPoint:
		var point = ThrowPoint.new()
		point.global_position = spot.global_position
		# NOTE: Check if throw spots are aligned properly in the scene.
		point.direction = spot.global_basis.y 
		return point
