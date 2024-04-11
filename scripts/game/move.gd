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
	_player = from.get_occupying_player()


# TODO: allow to choose animation type: direct or skipping
func execute() -> void:
	if _executed:
		return
	
	_executed = true
	
	var pieces = _from.remove_pieces()
	var knocked_out_pieces = await _to.place_pieces(pieces, Piece.MoveAnim.ARC)
	for piece in knocked_out_pieces:
		var starting_spot = _board.get_free_start_spots(_player).pick_random() as Spot
		starting_spot.place_piece(piece, Piece.MoveAnim.ARC) # WARNING: might need a sync barrier
