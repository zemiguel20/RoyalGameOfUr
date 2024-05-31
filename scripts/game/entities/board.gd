class_name Board extends Node3D
## Entity that represents the physical board. It defines the layout of the spots, having 2 starting
## zones and 2 tracks, one for each player.
## It provides queries about the spots and layout.


var p1_start_spots: Array[Spot] = []
var p1_track: Array[Spot] = []

var p2_start_spots: Array[Spot] = []
var p2_track: Array[Spot] = []


func _ready():
	p1_start_spots.assign(get_tree().get_nodes_in_group("p1_start_spots"))
	p2_start_spots.assign(get_tree().get_nodes_in_group("p2_start_spots"))
	
	p1_track.assign(get_tree().get_nodes_in_group("p1_track"))
	var p1_end_spot = get_tree().get_first_node_in_group("p1_end_spot") as Spot
	p1_track.append(p1_end_spot)
	
	p2_track.assign(get_tree().get_nodes_in_group("p2_track"))
	var p2_end_spot = get_tree().get_first_node_in_group("p2_end_spot") as Spot
	p2_track.append(p2_end_spot)


## Returns a copy of the array with all start spots from [param player].
func get_start_spots(player: int) -> Array[Spot]:
	if player == General.Player.ONE:
		return p1_start_spots.duplicate()
	else:
		return p2_start_spots.duplicate()


## Returns a new array with the start spots from [param player] without any pieces.
func get_free_start_spots(player : int) -> Array[Spot]:
	var free_spots = get_start_spots(player).filter(is_spot_free)
	return free_spots


## Returns a new array with the start spots from [param player] with a piece.
func get_occupied_start_spots(player: int) -> Array[Spot]:
	var occupied_spots = get_start_spots(player).filter(is_spot_occupied)
	return occupied_spots


## Returns a copy of the array with the spot sequence for the given [param player].
func get_track(player : int) -> Array[Spot]:
	if player == General.Player.ONE:
		return p1_track.duplicate()
	else:
		return p2_track.duplicate()


## Checks if the [param spot] does not have any piece.
func is_spot_free(spot: Spot) -> bool:
	return spot.pieces.is_empty()


## Checks if the [param spot] has a piece.
func is_spot_occupied(spot: Spot) -> bool:
	return not is_spot_free(spot)


## Returns whether the given [param spot] is exclusive to one of the player's track.
func is_spot_exclusive(spot: Spot) -> bool:
	return (p1_track.has(spot) and not p2_track.has(spot)) or \
	(not p1_track.has(spot) and p2_track.has(spot))


func get_landing_spot(player : int, spot: Spot, steps: int, backwards := false) -> Spot:
	var track = get_track(player)
	var index = track.find(spot) # NOTE: In this case, -1 means its a starting spot
	
	if not backwards and (index + steps) < track.size():
		return track[index + steps]
	
	if backwards and (index - steps) >= 0:
		return track[index - steps]
	
	var free_start_spots = get_free_start_spots(player)
	if backwards and (index - steps) == -1 and not free_start_spots.is_empty():
		return free_start_spots.pick_random()
	
	return null
