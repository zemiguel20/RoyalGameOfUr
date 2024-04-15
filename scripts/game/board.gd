class_name Board
extends Node
## Manages the state of the board. It stores in which spot the pieces of each player are.
## It allows queries to the state of the board, and also moves the pieces.

@export_subgroup("Player 1 Data")
@export var _p1_piece: PackedScene
@export var _p1_start_spots: Array[Spot]
@export var _p1_track: Array[Spot]
@export_subgroup("Player 2 Data")
@export var _p2_piece: PackedScene
@export var _p2_start_spots: Array[Spot]
@export var _p2_track: Array[Spot]

# Pack @export data per player into dictionary to reduce "if" statements
var _p_data: Dictionary = {}


func _ready() -> void:
	# Pack player data
	_p_data[General.Player.ONE] = [_p1_piece, _p1_start_spots, _p1_track]
	_p_data[General.Player.TWO] = [_p2_piece, _p2_start_spots, _p2_track]
	
	_check_player_data()
	_clean()
	_spawn_pieces()


func get_start_spots(player: General.Player) -> Array[Spot]:
	return (_p_data[player][1] as Array[Spot]).duplicate()


func get_free_start_spots(player: General.Player) -> Array[Spot]:
	var start_spots = get_start_spots(player)
	var free_spots = start_spots.filter(func(spot: Spot): return spot.is_free())
	return free_spots


func get_occupied_start_spots(player: General.Player) -> Array[Spot]:
	var start_spots = get_start_spots(player)
	var occupied_spots = start_spots.filter(func(spot: Spot): return not spot.is_free())
	return occupied_spots


func get_track(player: General.Player) -> Array[Spot]:
	return (_p_data[player][2] as Array[Spot]).duplicate()


func get_occupied_track_spots(player: General.Player, include_last := false) -> Array[Spot]:
	var track = get_track(player)
	if not include_last:
		track = track.slice(0, track.size() - 1)
	var occupied_spots = track.filter(func(spot: Spot): return spot.is_occupied(player))
	return occupied_spots


func get_possible_moves(player: General.Player, steps: int) -> Array[Move]:
	var moves: Array[Move] = []
	
	var occupied_spots: Array[Spot] = []
	occupied_spots.append_array(get_occupied_start_spots(player))
	occupied_spots.append_array(get_occupied_track_spots(player))
	
	# TODO: also do for backwards moves
	for spot in occupied_spots:
		var landing_spot = _get_landing_spot(spot, steps)
		if landing_spot != null and landing_spot.can_place(spot.get_pieces()):
			var move: Move = Move.new(spot, landing_spot, self)
			moves.append(move)
	
	return moves


func _get_landing_spot(spot: Spot, steps: int, backwards := false) -> Spot:
	var player = spot.get_pieces().front().player
	var track = get_track(player)
	var index = track.find(spot) # NOTE: In this case, -1 means its a starting spot
	
	if not backwards and (index + steps) < track.size():
		return track[index + steps]
	
	if backwards and (index - steps) >= 0:
		return track[index - steps]
	
	if backwards and (index - steps) == -1:
		return get_free_start_spots(player).pick_random()
	
	return null


#region SETUP

func _check_player_data():
	assert(_p1_piece != null, "No piece prefab was assigned to Player 1")
	assert(_p2_piece != null, "No piece prefab was assigned to Player 2")
	assert(_p1_start_spots.size() <= Settings.num_pieces, \
		"Player 1 does not have enough starting spots for the specified number of pieces")
	assert(_p2_start_spots.size() <= Settings.num_pieces, \
		"Player 2 does not have enough starting spots for the specified number of pieces")


# Clean spots and despawn pieces
func _clean():
	for player in _p_data:
		var all_spots: Array[Spot] = []
		all_spots.append_array(get_start_spots(player))
		all_spots.append_array(get_track(player))
		for spot in all_spots:
			var pieces = spot.remove_pieces()
			for piece in pieces:
				piece.queue_free()


func _spawn_pieces():
	for player in _p_data:
		for i in Settings.num_pieces:
			var piece = _p_data[player][0].instantiate()
			add_child(piece)
			var free_spot = get_free_start_spots(player).pick_random() as Spot
			free_spot.place_piece(piece, Piece.MoveAnim.NONE)

#endregion
