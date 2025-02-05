class_name TurnSummary


enum Result {
	NORMAL,
	EXTRA_TURN,
	WIN,
	NO_MOVES,
}

var turn_number: int = 0
var player: BoardGame.Player = BoardGame.Player.ONE
var roll: int = 0
var move: GameMove = null # If result is no moves than this is null
var result: Result = Result.NORMAL


static func create(p_turn_number: int, p_player: int, p_roll: int, p_move: GameMove) -> TurnSummary:
	var summary = TurnSummary.new()
	summary.turn_number = p_turn_number
	summary.player = p_player
	summary.roll = p_roll
	summary.move = p_move
	
	if p_move.wins:
		summary.result = Result.WIN
	elif p_move.gives_extra_turn:
		summary.result = Result.EXTRA_TURN
	else:
		summary.result = Result.NORMAL
	
	return summary


static func create_no_moves(p_turn_number: int, p_player: int, p_roll: int) -> TurnSummary:
	var summary = TurnSummary.new()
	summary.turn_number = p_turn_number
	summary.player = p_player
	summary.roll = p_roll
	summary.move = null
	summary.result = Result.NO_MOVES
	return summary


static func result_to_string(result: Result) -> StringName:
	if result == Result.NORMAL:
		return "Normal"
	elif result == Result.EXTRA_TURN:
		return "Extra_Turn"
	elif result == Result.WIN:
		return "Win"
	else:
		return "No_Moves"


static func player_to_string(player: BoardGame.Player) -> StringName:
	if player == BoardGame.Player.ONE:
		return "One"
	else:
		return "Two"


func to_json() -> Dictionary:
	var dict = {
		"turn_number" : turn_number,
		"player" : player_to_string(player),
		"roll" : roll,
		"move" : {} if result == Result.NO_MOVES else move.to_json(),
		"result" : result_to_string(result)
	}
	
	return dict
