class_name Move
## Data structure for a Move. Inspired in the Command pattern


var _from: Spot
var _to: Spot
var _manager: BoardGameManager


func _init(from: Spot, to: Spot, manager: BoardGameManager):
	_from = from
	_to = to
	_manager = manager


# TODO: allow to choose animation type: direct or skipping
func execute():
	var pieces = _from.remove_pieces()
	var knocked_out_pieces = await _to.place_pieces(pieces, Piece.MOVE_ANIM.ARC)
	for piece in knocked_out_pieces:
		var starting_spot = _manager.get_random_free_starting_spot()
		starting_spot.place_pieces([piece], Piece.MOVE_ANIM.ARC)
