class_name BoardGameManager
extends Node


@export var _starting_spots: Array[Spot]


func get_random_free_starting_spot() -> Spot:
	var free_spots = _starting_spots.filter(func(spot:Spot): spot.get_pieces().is_empty())
	return free_spots.pick_random()
