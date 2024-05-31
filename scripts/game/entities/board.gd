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
	var filter = func(spot: Spot): return spot.is_free()
	var free_spots = get_start_spots(player).filter(filter)
	return free_spots


## Returns a new array with the start spots from [param player] with a piece.
func get_occupied_start_spots(player: int) -> Array[Spot]:
	var filter = func(spot: Spot): return not spot.is_free()
	var occupied_spots = get_start_spots(player).filter(filter)
	return occupied_spots


## Returns a copy of the array with the spot sequence for the given [param player].
func get_track(player : int) -> Array[Spot]:
	if player == General.Player.ONE:
		return p1_track.duplicate()
	else:
		return p2_track.duplicate()


## Returns the spots of the given [param player] track occupied by self.
func get_track_spots_occupied_by_self(player: int) -> Array[Spot]:
	var track = get_track(player)
	var filter = func(spot: Spot): return spot.is_occupied_by_player(player)
	return track.filter(filter)


func is_spot_end_of_player_track(spot: Spot, player: int) -> bool:
	return spot == get_track(player).back()


## Returns whether the given [param spot] is exclusive to one of the player's sides.
func is_spot_exclusive(spot: Spot) -> bool:
	var p1_has = p1_start_spots.has(spot) or p1_track.has(spot)
	var p2_has = p2_start_spots.has(spot) or p2_track.has(spot)
	
	return (p1_has and not p2_has) or (p2_has and not p1_has)


## Returns whether the given [param spot] is exclusive to the given [param player] side.
func is_spot_exclusive_player(spot: Spot, player: int) -> bool:
	var player_has = get_start_spots(player).has(spot) or get_track(player).has(spot)
	
	var opponent = General.get_opponent(player)
	var opponent_has = get_start_spots(opponent).has(spot) or get_track(opponent).has(spot)
	
	return player_has and not opponent_has


## On the [param player] side, get the spots where you can land on in [param steps] from
## [param ref_spot]. The optional flag [param forward_only] locks calculation to
## forward movement in the track.
func get_landing_spots(player: int, ref_spot: Spot, steps: int, forward_only := false) -> Array[Spot]:
	# If ref_spot is exclusive, but its not from the given player, return
	if is_spot_exclusive_player(ref_spot, General.get_opponent(player)):
		push_error("Given spot does not exist in the given player side.")
		return []
	
	var track = get_track(player)
	var index = track.find(ref_spot) # NOTE: In this case, -1 means its a starting spot
	
	var landing_spots: Array[Spot] = []
	
	# Forward and within track bounds
	if (index + steps) < track.size():
		var spot = track[index + steps]
		landing_spots.append(spot)
	
	if not forward_only:
		# Backwards and within track bounds
		if (index - steps) >= 0:
			var spot = track[index - steps]
			landing_spots.append(spot)
		# Backwards and to starting area
		elif (index - steps) == -1:
			var spots = get_free_start_spots(player)
			landing_spots.append_array(spots)
	
	return landing_spots


## Get the path of spots between (inclusive) [param from] and [param to], in the [param player] track.
func get_path_between(from: Spot, to: Spot, player: int) -> Array[Spot]:
	var path: Array[Spot] = []
	var index_from = get_track(player).find(from)
	var index_to = get_track(player).find(to)
	# TODO: IMPLEMENT
	return path
