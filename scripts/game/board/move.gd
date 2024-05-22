class_name Move
## Contains information relative to a specific move. Can be executed like the command pattern.

signal execution_finished

## Base danger value for spots that are shared between both players' paths, and are not 100% safe.
const BASE_SHARED_SPOT_DANGER_SCORE: float = 0.1

var player: int ## Player making the move.
var from: Spot ## Spot where the move is coming from.
var to: Spot ## Spot where the move is going to.
var pieces_in_from: Array[Piece] ## Pieces placed in the [member from] spot (before execution).
var pieces_in_to: Array[Piece] ## Pieces placed in the [member to] spot (before execution). 
var knocks_opo: bool ## Whether knocks out opponent.
var moves_to_end: bool ## Whether [member to] is the end of the track.
var wins: bool ## Whether move wins the game.
var gives_extra_turn: bool ## Whether move gives player an extra turn
var is_from_central: bool  ## Whether [member from] is at the central/shared part of the track
var is_to_central: bool  ## Whether [member to] is at the central/shared part of the track
var from_track_pos: float ## Position of the [member from] spot in the track, as a value between 0 and 1.
var num_opo_pieces_ahead: int ## Number of opponent pieces ahead of the 'from' spot.
var safety_score: float ## Higher score means this moves pieces to a more safe spot.

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
	
	var is_almost_win = moves_to_end and \
			pieces_in_to.size() + pieces_in_from.size() == Settings.num_pieces
	wins = is_almost_win and moves_to_end
	
	gives_extra_turn = to.give_extra_turn
	
	is_from_central = not _board.is_spot_exclusive(from)
	is_to_central = not _board.is_spot_exclusive(to)
	
	from_track_pos = float(track.find(from) + 1) / float(track.size())
	
	num_opo_pieces_ahead = _get_num_opponent_pieces_ahead()
	
	safety_score = _calculate_danger_score(from) - _calculate_danger_score(to)


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
	
	if not knocked_out_pieces.is_empty():
		# Animation knock out
		for i in knocked_out_pieces.size():
			var piece = knocked_out_pieces[i] as Piece
			var spot = free_spots[i] as Spot
			piece.move(spot.global_position, General.MoveAnim.ARC)
		
		await (knocked_out_pieces.back() as Piece).movement_finished
	
	execution_finished.emit()


func _get_num_opponent_pieces_ahead() -> int:
	var from_index = _board.get_track(player).find(from)
	
	var num_pieces_ahead = 0
	var opponent = General.get_opponent(player)
	for occupied_spot in _board.get_occupied_track_spots(opponent, true):
		var index = _board.get_track(opponent).find(occupied_spot)
		if index > from_index:
			num_pieces_ahead += _board.get_spot_pieces(occupied_spot).size()
	
	return num_pieces_ahead


# 0 -> safe spot, 1 -> can be captured with any roll
func _calculate_danger_score(spot: Spot) -> float:
	# Give score of 0 when landing_spot is 100% safe. 
	if spot.is_safe or _board.is_spot_exclusive(spot):
		return 0
	
	var total_capture_chance = 0.0
	var index = _board.get_track(player).find(spot)
	var opponent_id = General.get_opponent(player) 
	
	# Check the tiles before this spot for opponent pieces
	for i in range(1, Settings.num_dice + 1):
		var temp_spot = _board.get_track(opponent_id)[index - i] as Spot
		var contains_opponent = _board.is_spot_occupied_by_player(temp_spot, opponent_id)
		if contains_opponent:
			var capture_chance = General.get_probability_of_value(i, Settings.num_dice)
			total_capture_chance += capture_chance
	
	# BASE_DANGER_SCORE is a simplified way of saying that even if direct chance of capture is 0,
	# the opponent might get an extra roll, instead of actually calculating the chances
	# of getting an extra roll.
	return BASE_SHARED_SPOT_DANGER_SCORE + total_capture_chance
