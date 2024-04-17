class_name Move
extends Object
## Contains information relative to a specific move. Can be executed like the command pattern.


var from: Spot
var to: Spot
var _board: Board
var _executed
var _player: General.Player


func _init(current_spot: Spot, target_spot: Spot, board: Board):
	from = current_spot
	to = target_spot
	_board = board
	_executed = false
	_player = from.get_pieces().front().player


# TODO: allow to choose animation type: direct or skipping
func execute() -> void:
	if _executed:
		return
	
	_executed = true
	
	var pieces = from.remove_pieces()
	var knocked_out_pieces = await to.place_pieces(pieces, Piece.MoveAnim.ARC)
	for piece in knocked_out_pieces:
		var opponent = knocked_out_pieces.front().player
		var starting_spot = _board.get_free_start_spots(opponent).pick_random() as Spot
		starting_spot.place_piece(piece, Piece.MoveAnim.ARC) # WARNING: might need a sync barrier


func gives_extra_roll() -> bool:
	return to.give_extra_roll


func is_winning_move() -> bool:
	if _executed:
		return _board.won(_player)
	else:
		var last_spot = _board.get_track(_player).back() as Spot
		var is_almost_win = last_spot.get_pieces().size() == Settings.num_pieces
		return is_almost_win and last_spot == to


func is_capture():
	return to._pieces.size() > 0 and to._pieces.front().player != _player 


func moves_to_end_zone():
	var last_spot = _board.get_track(_player).back() as Spot
	return last_spot == to


func get_track_progression():
	var current_tile_index = _board.get_spot_index(from, _player)
	var track_size = _board.get_track_size(_player)
	var progression: float = (current_tile_index + 1.0)/track_size		# Value between 0 and 1
	return progression
	
	
func num_pieces_past_spot():
	pass


func calculate_safety_difference(base_danger_score: float):
	var old_spot_danger = _calculate_spot_danger(from, base_danger_score)
	var new_spot_danger = _calculate_spot_danger(to, base_danger_score)
	var spot_safety_difference = old_spot_danger - new_spot_danger 	# Value between -1 and 1
	return spot_safety_difference



## Helper function for calculate_safety_difference()
func _calculate_spot_danger(spot: Spot, base_danger_score: float):
		# Give score of 0 when landing_spot is 100% safe. 
	if (spot.is_safe or gives_extra_roll() or _is_to_exclusive()):
		return 0
	
	# When a spot is not player exclusive, there is always a bit of danger.
	var total_capture_chance = 0.0
	# FIXME
	var index = _board.get_spot_index(spot, _player)
	# To Jose: Why exactly did you remove the General.get_opposite_player()?
	var opponent_id = General.Player.ONE if _player == General.Player.TWO else General.Player.TWO 
	
	# Check the 4 tiles before this spot for opponent pieces
	for _i in range(1, 5):
		var temp_spot := _board.get_spot(index - _i, opponent_id) as Spot
		var contains_opponent = temp_spot.is_occupied(opponent_id)
		if contains_opponent:
			# FIXME: Add dice to settings
			var capture_chance = DiceProbabilities.get_probability_of_value(_i, Settings._num_of_dice)
			total_capture_chance += capture_chance
	
	return total_capture_chance
	
	
# Could also move this to spot maybe?
func _is_central_rosette(spot: Spot) -> bool:
	return spot.is_safe and not _board.is_player_exclusive(spot)
	

## Returns whether the spot [param to] is exclusive to the player, 
## or if it is also on the track of the opponent.
func _is_to_exclusive():
	# FIXME
	return false
	return _board.is_spot_exclusive(to)
	
