class_name Tile
extends Spot

var piece : Piece 


func _sample_position():
	# Alternatively we can also have a Node3D export var, so we can specify a different position.
	# But I think it makes sense so far to use the position of the Node with this script.
	return global_position
