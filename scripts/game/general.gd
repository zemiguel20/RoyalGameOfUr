class_name General
extends Object
## Contains constants and general utility functions

enum PlayerID {ONE = 1, TWO = 2}
enum Result {NOTHING = 0, EXTRA_ROLL = 1, WON = 2}

static func get_other_player_id(id: PlayerID) -> PlayerID:
	return PlayerID.TWO if id == PlayerID.ONE else PlayerID.ONE


# Not tested yet.
static func get_random_position_in_boxshape_3D(shape : BoxShape3D) -> Vector3:
	var random_position = Vector3()
	random_position.x = randi_range(shape.position - shape.size.x/2, shape.position + shape.size.x/2)
	random_position.z = randi_range(shape.position - shape.size.z/2, shape.position + shape.size.z/2)
	return random_position
