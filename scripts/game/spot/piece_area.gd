extends Spot

# STACKED is basically also a line, but in the y-axis.
enum PlacementAlgorithm {
	LINE = 0,
	SCATTERED = 1,
}


@export var placement_algorithm : PlacementAlgorithm

@export_group("Line Placement")
# Offset, Starting point
@export var offset : Vector3 = Vector3(0, 0, 1)
var starting_position : Vector3

@export_group("Scattered Placement")
@export var spawning_area : BoxShape3D
@export var min_distance_to_other : float = 1


# Bunch of positions, and if they are taken or not.
# Dictionary of positions and pieces
var positions : Dictionary


func _ready():
	if (placement_algorithm == PlacementAlgorithm.LINE):
		starting_position = global_position


func append(piece: Piece):
	for position in positions.keys():
		if positions[position] == null:
			positions[position] = piece
			
	
func remove(piece: Piece):
	for position in positions.keys():
		if positions[position] == piece:
			positions[position] = null


# The weird part now with this function is that we return a position, and that a piece that 
# To fix that, we could pass in the Piece here and rename the function to something like enter_spot or append_piece.
func _sample_position():
	# Get free spot in positions
	for position in positions.keys():
		if positions[position] == null:
			return positions[position]
	
	# If no free spot was found, create new position according to algorithm
	if (placement_algorithm == PlacementAlgorithm.LINE):
		return _add_position_line()
	elif (placement_algorithm == PlacementAlgorithm.SCATTERED):
		return _add_position_scattered()
	
	
func _add_position_line():
	var num_of_positions = positions.size()
	var new_position = starting_position + num_of_positions * offset
	positions[new_position] = null
	return new_position
	
# Experimental and not optimized.
func _add_position_scattered():
	var num_of_positions = positions.size()
	var is_valid_position = false
	var new_position
	
	while not is_valid_position:
		new_position = General.get_random_position_in_boxshape_3D(spawning_area)
		is_valid_position = true
		# Loop through all of the pieces to check if this position is not too close.
		for position in positions.keys():
			if (new_position.distance_to(position) > min_distance_to_other):
				is_valid_position = false
				break
		
	return new_position
	
