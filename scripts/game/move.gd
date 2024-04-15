class_name Move
extends Object
## Contains information relative to a specific move. Can be executed like the command pattern.


var _from: Spot
var _to: Spot
var _board: Board
var _executed
var _player: General.Player


func _init(from: Spot, to: Spot, board: Board):
	_from = from
	_to = to
	_board = board
	_executed = false
	_player = from.get_pieces().front().player


# TODO: allow to choose animation type: direct or skipping
func execute() -> void:
	if _executed:
		return
	
	_executed = true
	
	var pieces = _from.remove_pieces()
	var knocked_out_pieces = await _to.place_pieces(pieces, Piece.MoveAnim.ARC)
	for piece in knocked_out_pieces:
		var opponent = knocked_out_pieces.front().player
		var starting_spot = _board.get_free_start_spots(opponent).pick_random() as Spot
		starting_spot.place_piece(piece, Piece.MoveAnim.ARC) # WARNING: might need a sync barrier


func gives_extra_roll() -> bool:
	return _to.give_extra_roll


func is_winning_move() -> bool:
	if _executed:
		return _board.won(_player)
	else:
		var last_spot = _board.get_track(_player).back() as Spot
		var is_almost_win = last_spot.get_pieces().size() == Settings.num_pieces
		return is_almost_win and last_spot == _to
