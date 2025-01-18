class_name GameMove
## Represents an action of moving pieces in one spot to another spot.
## Contains specific information, such has if it is a direct winning move.
## Can be executed, like the command pattern.


signal execution_finished

enum AnimationType {
	SKIPPING,
	DIRECT,
}

const ANIM_DURATION_SEC = 0.4
const ARC_HEIGHT_M = 0.04

var player: int ## Player making the move.
var from: Spot ## Move's starting spot.
var to: Spot ## Move's landing spot.
var from_track_index: int ## [member from] spot index in the track.
var pieces_in_from: Array[Piece] ## Pieces in [member from] before execution.
var from_is_safe: bool
var to_track_index: int ## [member to] spot index in the track.
var pieces_in_to: Array[Piece] ## Pieces in [member to] before execution.
var to_is_safe: bool
var to_is_end_of_track: bool
var full_path: Array[Spot] ## Full path between [member from] and [member to].
var is_backwards: bool ## Whether its moving backwards in the path.
var knocks_opponent_out: bool
var wins: bool
var gives_extra_turn: bool

var _executed: bool = false # Whether move has already been executed
var _board: Board


func _init(p_from: Spot, p_to: Spot, p_player: int, board: Board, ruleset: Ruleset):
	_board = board
	
	player = p_player
	from = p_from
	to = p_to
	
	# Shared variables for initialization
	var track = _board.get_player_track(player)
	
	from_track_index = track.find(from)
	pieces_in_from = from.pieces.duplicate()
	pieces_in_from.make_read_only()
	from_is_safe = _board.is_spot_safe(from, ruleset)
	
	to_track_index = track.find(to)
	pieces_in_to = to.pieces.duplicate()
	pieces_in_to.make_read_only()
	to_is_safe = _board.is_spot_safe(to, ruleset)
	to_is_end_of_track = to == track.back()
	
	full_path = _board.get_path_between(from_track_index, to_track_index, player)
	full_path.push_front(from)
	full_path.push_back(to)
	full_path.make_read_only()
	is_backwards = from_track_index > to_track_index
	
	var to_is_occupied_by_opponent = not to.is_free() and not to.is_occupied_by_player(player)
	knocks_opponent_out = to_is_occupied_by_opponent and not to_is_safe
	
	wins = to_is_end_of_track and pieces_in_to.size() + pieces_in_from.size() == ruleset.num_pieces
	
	gives_extra_turn = (ruleset.rosettes_give_extra_turn and to.is_rosette) \
		or (ruleset.captures_give_extra_turn and knocks_opponent_out)


## Updated the board state accordingly, and optionally can play piece movement animations.
func execute(animation_type: AnimationType) -> void:
	if _executed:
		return
	_executed = true
	
	# INFO: this is a confusing procedure. First, the pieces are animated accordingly,
	# and after that the spot data is updated, that is, from the game's perspective,
	# the pieces are only placed on the spots after the animations are completed.
	#
	# In case of a knockout, for the pieces not to overlap, animating moving to the spot and
	# animating the knockout happens simultaneously.
	# For the skipping animation, that means that the pieces are first animated along the path
	# but only up until before the landing spot.
	# Then, start the animation to the landing spot, resolve the knockout, and finally
	# update the spot data.
	
	
	# Remove the pieces from the spot and reparent to the piece at the base,
	# since this one is animated and all others will follow by consequence.
	var pieces_to_move = from.remove_pieces()
	var base_piece = pieces_to_move.front() as Piece
	for piece: Piece in pieces_to_move.slice(1):
		piece.reparent(base_piece)
	
	
	# KO pieces are removed early for the animation placing position
	var pieces_to_ko: Array[Piece] = []
	if knocks_opponent_out:
		pieces_to_ko.assign(to.remove_pieces())
	
	
	if animation_type == AnimationType.SKIPPING:
		# Animate the pieces along the path up until before the landing spot
		var anim_path = full_path.duplicate()
		anim_path.pop_front()
		anim_path.pop_back()
		for spot: Spot in anim_path:
			var target_pos = spot.get_placing_position_global()
			base_piece.move_arc(target_pos, ANIM_DURATION_SEC, ARC_HEIGHT_M)
			await base_piece.movement_finished
		
		# Start animation to landing spot
		var target_pos = to.get_placing_position_global()
		base_piece.move_arc(target_pos, ANIM_DURATION_SEC, ARC_HEIGHT_M)
	else:
		# Start direct animation to landing spot
		var target_pos = to.get_placing_position_global()
		base_piece.move_line(target_pos, ANIM_DURATION_SEC)
	
	if knocks_opponent_out:
		# Animate knockout pieces to starting zone
		var opponent = (pieces_to_ko.front() as Piece).player
		var free_start_spots = _board.get_player_free_start_spots(opponent)
		free_start_spots.shuffle()
		for i in pieces_to_ko.size():
			var piece = pieces_to_ko[i]
			var spot = free_start_spots[i]
			piece.move_arc(spot.get_placing_position_global(), ANIM_DURATION_SEC, ARC_HEIGHT_M)
		await (pieces_to_ko.front() as Piece).movement_finished
		
		# Update state
		for i in pieces_to_ko.size():
			var piece = pieces_to_ko[i]
			var spot = free_start_spots[i]
			spot.place(piece)
	
	# Finalize move
	if base_piece.moving:
		await base_piece.movement_finished
	to.place_stack(pieces_to_move)
	
	execution_finished.emit()
