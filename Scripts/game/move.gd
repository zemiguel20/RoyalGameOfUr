class_name Move

## Data structure for 
## For now, this is most of the data needed by the AI to evaluate moves.
var piece: Piece
var spot: Spot
var is_safe: bool
var is_capture: bool

func _init(piece, spot, is_safe, is_capture):
    self.piece = piece
    self.spot = spot
    self.is_safe = is_safe
    self.is_capture = is_capture