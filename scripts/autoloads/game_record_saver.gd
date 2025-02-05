extends Node


var request: HTTPRequest
var sending_file := false
const filename_format = "ur_%s_%s.json"


func _ready():
	request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(_on_request_completed)


func save_game_record_to_file(record: GameRecord) -> void:
	var json = JSON.stringify(record.to_json(), "\t", false)
	var filename = filename_format % [record.game_version, record.uuid]
	var file = FileAccess.open("user://%s" % filename, FileAccess.WRITE)
	file.store_string(json)


# TESTING
func send_game_record_to_server(record: GameRecord, server_url: String) -> void:
	if sending_file:
		return
	
	sending_file = true
	
	var filename = filename_format % [record.game_version, record.uuid]
	var file_content = JSON.stringify(record.to_json(), "\t", false)
	
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
	
	var error = request.request_raw(server_url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_request_completed(result: int, response_code: int, _headers, _body) -> void:
	sending_file = false
	print("Result code: %d; Response code: %d" % [result, response_code])
