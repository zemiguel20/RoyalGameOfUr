class_name Move
## Contains information relative to a specific move. Can be executed like the command pattern.

signal execution_finished

var player : int ## Player making the move.
var from : Spot ## Spot where the move is coming from.
var to : Spot ## Spot where the move is going to.
var pieces_in_from : Array[Piece] ## Pieces placed in the [member from] spot (before execution).
var pieces_in_to : Array[Piece] ## Pieces placed in the [member to] spot (before execution). 
var knocks_opo : bool ## Whether knocks out opponent.
var moves_to_end : bool ## Whether [member to] is the end of the track.
var wins : bool ## Whether move wins the game.
var gives_extra_turn : bool ## Whether move gives player an extra turn
var is_from_central_safe : bool  ## Whether [member from] is a safe spot at the central/shared part of the track
var is_to_central_safe : bool  ## Whether [member to] is a safe spot at the central/shared part of the track
var from_track_pos : float ## Position of the [member from] spot in the track, as a value between 0 and 1.

var _board : Board # Access to board state
var _executed : bool # Whether move has already been executed


func _init(board : Board, player : int, from : Spot, to : Spot):
	# Private variables
	_board = board
	_executed = false
	
	# Shared variables for initialization
	var track = _board.get_track(player)
	
	# Initialize properties
	self.from = from
	self.to = to
	self.player = player
	
	pieces_in_from = _board.get_spot_pieces(from)
	pieces_in_from.make_read_only()
	pieces_in_to = _board.get_spot_pieces(to)
	pieces_in_to.make_read_only()
	
	knocks_opo = _board.is_spot_occupied_by_player(to, General.get_opponent(player))
	
	moves_to_end = to == track.back()
	
	var is_almost_win = _board.get_spot_pieces(track.back()).size() == (Settings.num_pieces - 1)
	wins = is_almost_win and moves_to_end
	
	gives_extra_turn = to.give_extra_turn
	
	is_from_central_safe = from.is_safe and not _board.is_spot_exclusive(from)
	is_to_central_safe = to.is_safe and not _board.is_spot_exclusive(to)
	
	from_track_pos = float(track.find(from) + 1) / float(track.size())


## Updated the board state accordingly, and optionally can play piece movement animations.
func execute(animation := General.MoveAnim.NONE) -> void:
	if _executed:
		return
	
	_executed = true
	
	# Create copies of the piece arrays for safety
	var p_from_copy = pieces_in_from.duplicate()
	var p_to_copy = pieces_in_to.duplicate()
	
	# Sort pieces by ascending height (stack order base to top)
	var ascending_stack_sort = func(p1, p2): return p1.global_position.y < p2.global_position.y
	p_from_copy.sort_custom(ascending_stack_sort)
	p_to_copy.sort_custom(ascending_stack_sort)
	
	# If knocks out pieces, remove them from 'to' and store them on the side to later move them
	var knocked_out_pieces : Array[Piece] = []
	if knocks_opo:
		knocked_out_pieces = p_to_copy.duplicate()
		p_to_copy.clear()
	
	# Update board state moved pieces
	for piece in p_from_copy:
		_board._get_player_data(player).piece_spot_dict[piece] = to
	# Update board state knocked out pieces
	var free_spots = _board.get_free_start_spots(General.get_opponent(player))
	free_spots.shuffle() # Randomize spot assignment
	for i in knocked_out_pieces.size():
		var piece = knocked_out_pieces[i] as Piece
		var spot = free_spots[i] as Spot
		_board._get_player_data(General.get_opponent(player)).piece_spot_dict[piece] = spot
	
	# Animations move pieces
	var offset = Vector3.UP * (pieces_in_from.front() as Piece).get_height_scaled()
	var base_pos = to.global_position + (p_to_copy.size() * offset)
	for i in p_from_copy.size():
		var piece = p_from_copy[i] as Piece
		var target_pos = base_pos + (i * offset)
		piece.move(target_pos, animation)
	
	await (p_from_copy.back() as Piece).movement_finished
	
	# Animation knock out
	for i in knocked_out_pieces.size():
		var piece = knocked_out_pieces[i] as Piece
		var spot = free_spots[i] as Spot
		piece.move(spot.global_position, General.MoveAnim.ARC)
	
	await (knocked_out_pieces.back() as Piece).movement_finished
	
	execution_finished.emit()


func num_pieces_past_current_spot():
	var spot_index = _board.get_track(player).find(from)
	
	var num_passed_pieces = 0
	var opponent = General.get_opponent(player)
	for occupied_spot in _board.get_occupied_track_spots(opponent, true):
		var index = _board.get_track(opponent).find(occupied_spot)
		if index > spot_index:
			num_passed_pieces += _board.get_spot_pieces(occupied_spot).size()
	
	return num_passed_pieces


func calculate_safety_difference(base_danger_score: float):
	var old_spot_danger = _calculate_spot_danger(from, base_danger_score)
	var new_spot_danger = _calculate_spot_danger(to, base_danger_score)
	var spot_safety_difference = old_spot_danger - new_spot_danger 	# Value between -1 and 1
	return spot_safety_difference


# Helper function for calculate_safety_difference()
func _calculate_spot_danger(spot: Spot, base_danger_score: float):
	# Give score of 0 when landing_spot is 100% safe. 
	if spot.is_safe or _board.is_spot_exclusive(spot) or gives_extra_turn and spot == to:
		return 0
	
	var total_capture_chance = 0.0
	var index = _board.get_track(player).find(spot)
	var opponent_id = General.get_opponent(player) 
	
	# Check the 4 tiles before this spot for opponent pieces
	for i in range(1, 5):
		var temp_spot = _board.get_track(opponent_id)[index - i] as Spot
		var contains_opponent = _board.is_spot_occupied_by_player(temp_spot, opponent_id)
		if contains_opponent:
			var capture_chance = DiceProbabilities.get_probability_of_value(i, Settings.num_dice)
			total_capture_chance += capture_chance
	
	return total_capture_chance + base_danger_score
