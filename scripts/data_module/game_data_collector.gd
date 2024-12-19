extends Node


var current_game_data: GameRecord
var current_turn: TurnSnapshot
var turn_start_time_msec: int = 0

var request: HTTPRequest
var sending_file := false
const filename_format = "ur_%s_%s.dat"
const file_server_url = "https://ingest.lucdh.nl/"


func _ready():
	GameEvents.game_started.connect(_on_game_started)
	GameEvents.new_turn_started.connect(_on_new_turn_started)
	GameEvents.rolled.connect(_on_dice_rolled)
	GameEvents.no_moves.connect(_on_no_moves)
	GameEvents.move_executed.connect(_on_move_executed)
	GameEvents.game_ended.connect(_on_game_ended)
	
	request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_request_completed)


func _on_game_started() -> void:
	current_game_data = \
		GameRecord.create_with_empty_history(GameManager.ruleset, GameManager.is_hotseat)


func _on_new_turn_started() -> void:
	current_turn = TurnSnapshot.new()
	current_turn.number = GameManager.turn_number
	current_turn.player = GameManager.current_player
	
	turn_start_time_msec = Time.get_ticks_msec()


func _on_dice_rolled(value: int) -> void:
	current_turn.rolled_value = value


func _on_no_moves() -> void:
	current_turn.duration_msec = Time.get_ticks_msec() - turn_start_time_msec
	current_turn.turn_skipped = true
	current_game_data.history.append(current_turn)


func _on_move_executed(move: GameMove) -> void:
	current_turn.duration_msec = Time.get_ticks_msec() - turn_start_time_msec
	current_turn.executed_move = GameMoveSnapshot.create_from(move)
	current_game_data.history.append(current_turn)


func _on_game_ended() -> void:
	var json = JSON.stringify(current_game_data.to_dict(), "\t", false)
	var filename = filename_format % [current_game_data.game_version, current_game_data.uuid]
	var file = FileAccess.open("user://%s" % filename, FileAccess.WRITE)
	file.store_string(json)


# TESTING
func send_game_record_to_server() -> void:
	if sending_file:
		return
	
	sending_file = true
	
	var filename = filename_format % [current_game_data.game_version, current_game_data.uuid]
	var file = FileAccess.open("user://%s" % filename, FileAccess.READ)
	var file_content = file.get_as_text()
	
	var headers = [
		"Content-Type: multipart/form-data; boundary=BodyBoundaryHere"
	]
	
	var body = PackedStringArray([
		"\r\n--BodyBoundaryHere\r\n",
		"Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n" % filename,
		"Content-Type: text/json\r\n\r\n",
		file_content,
		"\r\n--BodyBoundaryHere--\r\n",
	]).to_byte_array()
	
	var error = request.request_raw(file_server_url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_request_completed(result: int, response_code: int, _headers, _body) -> void:
	sending_file = false
	print("Result code: %d; Response code: %d" % [result, response_code])


class GameRecord:
	var uuid: String = StringName(UUID.v4())
	var game_version: String = ProjectSettings.get_setting("application/config/version")
	var ruleset: Ruleset
	var is_hotseat: bool = false
	var history: Array[TurnSnapshot] = []
	
	@warning_ignore("shadowed_variable")
	static func create_with_empty_history(ruleset: Ruleset, hotseat: bool) -> GameRecord:
		var record = GameRecord.new()
		record.ruleset = ruleset.duplicate(true)
		record.is_hotseat = hotseat
		return record
	
	func to_dict() -> Dictionary:
		var dict = {
			"uuid" : uuid,
			"game_version" : game_version,
			"ruleset" : ruleset.to_dict(),
			"is_hotseat" : is_hotseat,
			"turn_history" : history.map(func(turn: TurnSnapshot): return turn.to_dict()),
		}
		
		return dict


class TurnSnapshot:
	var number: int = 0
	var player: int = 0
	var duration_msec: int = 0
	var rolled_value: int = 0
	var turn_skipped: bool = false
	var executed_move: GameMoveSnapshot
	
	func to_dict() -> Dictionary:
		var dict = {
			"turn_number" : number,
			"player" : player,
			"duration_msec" : duration_msec,
			"rolled_value" : rolled_value,
			"turn_skipped" : turn_skipped,
			"executed_move" : {} if turn_skipped else executed_move.to_dict(),
		}
		
		return dict


class GameMoveSnapshot:
	var from: int = 0 ## Order in player track
	var to: int = 0 ## Order in player track
	var pieces_in_from: int = 0 ## Count
	var pieces_in_to: int = 0 ## Count
	var captures: bool = false ## If this move is capturing spot from opponent
	var gives_extra_turn: bool = false
	
	static func create_from(move: GameMove) -> GameMoveSnapshot:
		var snapshot = GameMoveSnapshot.new()
		snapshot.from = move.from_track_index + 1
		snapshot.to = move.to_track_index + 1
		snapshot.pieces_in_from = move.pieces_in_from.size()
		snapshot.pieces_in_to = move.pieces_in_to.size()
		snapshot.captures = move.is_to_occupied_by_opponent
		snapshot.gives_extra_turn = move.gives_extra_turn
		
		return snapshot
	
	func to_dict() -> Dictionary:
		var dict = {
			"from" : from,
			"to" : to,
			"pieces_in_from" : pieces_in_from,
			"pieces_in_to" : pieces_in_to,
			"captures" : captures,
			"gives_extra_turn" : gives_extra_turn,
		}
		
		return dict
