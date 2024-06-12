class_name GameMove
## Represents an action of moving pieces in one spot to another spot.
## Contains specific information, such has if it is a direct winning move.
## Can be executed, like the command pattern.
##
## If tagged as invalid, cannot be executed. Invalid moves can still be displayed to the
## player for clarity purposes.


signal execution_finished

var player: int ## Player making the move.

# From spot info
var from: Spot ## Spot where the move is coming from.
var pieces_in_from: Array[Piece] ## Pieces placed in the [member from] spot (before execution).
var is_from_shared: bool  ## Whether [member from] is in both player's tracks.
var is_from_safe: bool ## Whether [member from] is a safe spot.
var from_track_pos: float ## Position of the [member from] spot in the track, as a value between 0 and 1.

# To spot info
var to: Spot ## Spot where the move is going to.
var pieces_in_to: Array[Piece] ## Pieces placed in the [member to] spot (before execution).
var is_to_shared: bool  ## Whether [member to] is in both player's tracks.
var is_to_safe: bool ## Whether [member to] is a safe spot.
var is_to_end_of_track: bool ## Whether [member to] is the end of the track.
var is_to_occupied_by_opponent: bool

# Path info
var full_path: Array[Spot] ## Full path between [member from] and [member to].
var backwards: bool ## Whether its moving backwards in the board.

# Move info
var valid: bool ## Whether this move is valid and can be executed.
var wins: bool ## Whether move wins the game.
var gives_extra_turn: bool ## Whether move gives player an extra turn

var _executed: bool = false # Whether move has already been executed
var _board: Board


@warning_ignore("shadowed_variable")
func _init(from: Spot, to: Spot, player: int):
	_board = EntityManager.get_board()
	
	# Shared variables for initialization
	var track = _board.get_track(player)
	
	# Initialize properties
	self.player = player
	
	# Get FROM spot info
	self.from = from
	pieces_in_from = from.pieces.duplicate()
	pieces_in_from.make_read_only()
	is_from_shared = not _board.is_spot_exclusive(from)
	is_from_safe = _is_spot_safe(from)
	from_track_pos = float(track.find(from) + 1) / float(track.size())
	
	# Get TO spot info
	self.to = to
	pieces_in_to = to.pieces.duplicate()
	pieces_in_to.make_read_only()
	is_to_shared = not _board.is_spot_exclusive(to)
	is_to_safe = _is_spot_safe(to)
	is_to_end_of_track = to == track.back()
	is_to_occupied_by_opponent = to.is_occupied_by_player(General.get_opponent(player))
	
	# Path info
	full_path = _board.get_path_between(from, to, player)
	full_path.make_read_only()
	backwards = track.find(from) > track.find(to)
	
	valid = _check_valid()
	
	wins = is_to_end_of_track and \
		pieces_in_to.size() + pieces_in_from.size() == Settings.ruleset.num_pieces
	
	if Settings.ruleset.rosettes_give_extra_turn and to.is_in_group("rosettes"):
		gives_extra_turn = true
	elif Settings.ruleset.captures_give_extra_turn and is_to_occupied_by_opponent:
		gives_extra_turn = true
	else:
		gives_extra_turn = false


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
	if is_to_occupied_by_opponent:
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


# Check if any rules are violated, or return true.
func _check_valid() -> bool:
	var result = true
	
	# Cant knockopponent out of a safe rosette
	if is_to_safe and is_to_occupied_by_opponent:
		result = false
	
	# Cannot stack in rosettes if setting not enabled
	if not Settings.ruleset.rosettes_allow_stacking \
	and to.is_in_group("rosettes") \
	and to.is_occupied_by_player(player):
		result = false
	
	# Cannot stack in normal spots
	if not to.is_in_group("rosettes") and to.is_occupied_by_player(player) and not is_to_end_of_track:
		result = false
	
	# Cannot stack in starting spots
	if Settings.ruleset.can_move_backwards and _board.get_occupied_start_spots(player).has(to):
		result = false
	
	# Cannot move pieces already in finish line
	if Settings.ruleset.can_move_backwards and from == _board.get_track(player).back():
		result = false
	
	return result


func _is_spot_safe(spot: Spot) -> bool:
	return _board.is_spot_exclusive(spot) or \
		(spot.is_in_group("rosettes") and Settings.ruleset.rosettes_are_safe)


func captures_opponent() -> bool:
	return is_to_occupied_by_opponent and _check_valid()
