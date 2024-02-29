class_name Move

## Data structure for a Move.
## For now, this is most of the data needed by the AI to evaluate moves.
var piece: Piece
var old_spot: Spot
var new_spot: Spot
var is_safe: bool
var grants_extra_roll: bool
var is_capture: bool

func _init(piece, old_spot, new_spot, is_safe, grants_extra_roll, is_capture):
	self.piece = piece
	self.old_spot = old_spot
	self.new_spot = new_spot
	self.is_safe = is_safe
	self.grants_extra_roll = grants_extra_roll
	self.is_capture = is_capture
