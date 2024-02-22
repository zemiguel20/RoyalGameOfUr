class_name General
extends Object
## Contains constants and general utility functions

enum PlayerID {ONE = 1, TWO = 2}

static func get_other_player_id(id: PlayerID) -> PlayerID:
	return PlayerID.TWO if id == PlayerID.ONE else PlayerID.ONE
