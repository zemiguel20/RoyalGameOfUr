class_name Move

## Data structure for a Move.
## For now, this is most of the data needed by the AI to evaluate moves.
var piece: Piece
var old_spot: Spot
var new_spot: Spot

func _init(piece, old_spot, new_spot):
	self.piece = piece
	self.old_spot = old_spot
	self.new_spot = new_spot
