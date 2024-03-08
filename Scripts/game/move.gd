class_name Move

## Data structure for a Move.
## From this data, AI is able to get more specific information about the move from the Board.gd class.
var piece: Piece
var old_spot: Spot
var new_spot: Spot

func _init(piece, old_spot, new_spot):
	self.piece = piece
	self.old_spot = old_spot
	self.new_spot = new_spot
