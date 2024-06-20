class_name EndScreen extends CanvasLayer


const WIN_SINGLEPLAYER_TEXT = "You have won!"
const LOSE_SINGLEPLAYER_TEXT = "You have lost!"
const HOTSEAT_TEXT = "Player %d won the game"


const survey_link: String = "https://www.universiteitleiden.nl/"

@export var test: bool = false
@export var test_is_hotseat: bool = false


@export_group("References")
@export var header_label: Label
@export var survey_menu: Control
@export var end_menu: Control
@export var survey_button: LinkButton
@export var send_file_button: Button


func _ready() -> void:
	visible = test
	GameEvents.game_ended.connect(_on_game_ended)
	
	if test:
		GameManager.is_hotseat = test_is_hotseat
		_on_game_ended()


func _on_game_ended() -> void:
	visible = true
	var winner = GameManager.current_player
	
	survey_menu.show()
	send_file_button.disabled = false
	# Set survey link with the game ID attached
	survey_button.uri = survey_link + "?gameid=" + GameDataCollector.current_game_data.uuid
	
	end_menu.hide()
	
	# Set title
	if GameManager.is_hotseat:
		header_label.text = HOTSEAT_TEXT % (winner + 1)
	else:
		if winner == General.Player.ONE:
			header_label.text = WIN_SINGLEPLAYER_TEXT
		else:
			header_label.text = LOSE_SINGLEPLAYER_TEXT


func _on_rematch_button_pressed() -> void:
	visible = false
	
	if test: return
	
	GameManager.is_rematch = true
	GameEvents.play_pressed.emit()
	GameManager.start_new_game()


func _on_main_menu_button_pressed() -> void:
	visible = false
	GameEvents.back_to_main_menu_pressed.emit()


func _on_continue_button_pressed() -> void:
	survey_menu.visible = false
	end_menu.visible = true


func _on_send_game_file_button_pressed() -> void:
	GameDataCollector.send_game_record_to_server()
	send_file_button.disabled = true
