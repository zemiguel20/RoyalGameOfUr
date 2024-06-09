class_name GameMove
## Represents an action of moving pieces in one spot to another spot.
## Contains specific information, such has if it is a direct winning move.
## Can be executed, like the command pattern.
##
## If tagged as invalid, cannot be executed. Invalid moves can still be displayed to the
## player for clarity purposes.


signal execution_finished

## Base danger value for spots that are shared between both players' paths, and are not 100% safe.
const BASE_SHARED_SPOT_DANGER_SCORE: float = 0.1

var player: int ## Player making the move.
var from: Spot ## Spot where the move is coming from.
var to: Spot ## Spot where the move is going to.
var full_path: Array[Spot] ## Full path between [member from] and [member to].
var pieces_in_from: Array[Piece] ## Pieces placed in the [member from] spot (before execution).
var pieces_in_to: Array[Piece] ## Pieces placed in the [member to] spot (before execution).
var valid: bool ## Whether this move is valid and can be executed.
var knocks_opo: bool ## Whether knocks out opponent.
var moves_to_end: bool ## Whether [member to] is the end of the track.
var wins: bool ## Whether move wins the game.
var gives_extra_turn: bool ## Whether move gives player an extra turn
var is_from_central: bool  ## Whether [member from] is at the central/shared part of the track
var is_to_central: bool  ## Whether [member to] is at the central/shared part of the track
var from_track_pos: float ## Position of the [member from] spot in the track, as a value between 0 and 1.
var num_opo_pieces_ahead: int ## Number of opponent pieces ahead of the 'from' spot.
var safety_score: float ## Higher score means this moves pieces to a more safe spot.

var _executed: bool = false # Whether move has already been executed
var _board: Board


@warning_ignore("shadowed_variable")
func _init(from: Spot, to: Spot, player: int, valid: bool):
	_board = EntityManager.get_board()
	
	# Shared variables for initialization
	var track = _board.get_track(player)
	
	# Initialize properties
	self.from = from
	self.to = to
	self.player = player
	self.valid = valid
	
	pieces_in_from = from.pieces.duplicate()
	pieces_in_from.make_read_only()
	pieces_in_to = to.pieces.duplicate()
	pieces_in_to.make_read_only()
	
	full_path = _board.get_path_between(from, to, player)
	full_path.make_read_only()
	
	knocks_opo = to.is_occupied_by_player(General.get_opponent(player)) if valid else false
	
	moves_to_end = to == track.back() if valid else false
	
	wins = moves_to_end and pieces_in_to.size() + pieces_in_from.size() == Settings.num_pieces
	
	gives_extra_turn = to.give_extra_turn if valid else false
	
	is_from_central = not _board.is_spot_exclusive(from)
	is_to_central = not _board.is_spot_exclusive(to)
	
	from_track_pos = float(track.find(from) + 1) / float(track.size())
	
	num_opo_pieces_ahead = _get_num_opponent_pieces_ahead()
	
	safety_score = _calculate_danger_score(from) - _calculate_danger_score(to)


## Updated the board state accordingly, and optionally can play piece movement animations.
func execute(animation := General.MoveAnim.NONE, follow_path := false) -> void:
	if _executed or not valid:
		return
	
	_executed = true
	
	# If follow_path is true, then this will be the full path.
	# Otherwise its only the from and to spots.
	var movement_path: Array[Spot] = []
	
	if follow_path:
		# NOTE: because this is only for animation, to not change the spot data along the path, 
		# temporary spots are used as in-between path spots.
		
		# Get between spots (without from and to)
		var between_spots: Array[Spot] = full_path.duplicate()
		between_spots.pop_back()
		between_spots.pop_front()
		
		# Create temporary spots and add them to path
		for spot in between_spots:
			var temp_spot = EntityManager.spawn_temporary_spot()
			temp_spot.global_position = spot.get_placing_position_global()
			movement_path.append(temp_spot)
	
	# Add 'from' and 'to' to the movement path
	movement_path.push_front(from)
	movement_path.push_back(to)
	
	# Move pieces along the path
	# NOTE: EXCEPT to the 'to' spot. First we have to deal with pieces being knocked out
	# and only then do we finish the movement.
	for i in movement_path.size() - 2:
		var current_spot = movement_path[i]
		var next_spot = movement_path[i + 1]
		current_spot.move_pieces_to_spot(next_spot, animation)
		await current_spot.pieces_moved
	
	# Move knockout pieces to starting zone
	if knocks_opo:
		var opponent_start_spots = _board.get_free_start_spots(General.get_opponent(player))
		movement_path[-1].move_pieces_split_to_spots(opponent_start_spots, General.MoveAnim.ARC)
		GameEvents.reaction_piece_captured.emit(self)
	
	# Move pieces to last spot
	movement_path[-2].move_pieces_to_spot(movement_path[-1], animation)
	# NOTE: the knockout animation and placing animation in last spot run simultaneously
	# wait for animations to finish
	await movement_path[-2].pieces_moved
	
	# Cleanup temporary spots
	movement_path.pop_back()
	movement_path.pop_front()
	for temp_spot in movement_path:
		temp_spot.queue_free()
	
	execution_finished.emit()


func _get_num_opponent_pieces_ahead() -> int:
	var from_index = _board.get_track(player).find(from)
	
	var num_pieces_ahead = 0
	var opponent = General.get_opponent(player)
	for occupied_spot in _board.get_track_spots_occupied_by_self(opponent):
		var index = _board.get_track(opponent).find(occupied_spot)
		if index > from_index:
			num_pieces_ahead += occupied_spot.pieces.size()
	
	return num_pieces_ahead


# 0 -> safe spot, higher means more danger
func _calculate_danger_score(spot: Spot) -> float:
	# Give score of 0 when landing_spot is 100% safe. 
	if spot.safe or _board.is_spot_exclusive(spot):
		return 0
	
	var danger_score = 0.0
	var opponent = General.get_opponent(player) 
	
	# Check the tiles before this spot for opponent pieces
	for i in range(1, Settings.num_dice + 1):
		var nearby_spots = _board.get_landing_spots(opponent, spot, i, not Settings.can_move_backwards)
		for near_spot in nearby_spots:
			if spot.is_occupied_by_player(opponent):
				danger_score += General.get_probability_of_value(i, Settings.num_dice)
	
	# BASE_DANGER_SCORE is a simplified way of saying that even if direct chance of capture is 0,
	# the opponent might get an extra roll, instead of actually calculating the chances
	# of getting an extra roll.
	return BASE_SHARED_SPOT_DANGER_SCORE + danger_score
