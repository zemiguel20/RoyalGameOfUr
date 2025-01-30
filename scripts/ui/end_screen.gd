class_name EndScreen
extends CanvasLayer


signal rematch_pressed
signal exit_pressed

const WIN_SINGLEPLAYER_TEXT = "You have won!"
const LOSE_SINGLEPLAYER_TEXT = "You have lost!"
const HOTSEAT_TEXT = "Player %d won the game"

# INFO: must be filled in accordingly
const SURVEY_LINK: String = "https://www.universiteitleiden.nl/"


@onready var _header_label: Label = $TabletPanel/HeaderLabel
@onready var _survey_menu: Control = $TabletPanel/SurveyMenu
@onready var _send_game_file_button: Button = $TabletPanel/SurveyMenu/Buttons/SendGameFileButton
@onready var _continue_button: Button = $TabletPanel/SurveyMenu/Buttons/ContinueButton
@onready var _end_menu: Control = $TabletPanel/EndMenu
@onready var _rematch_button: Button = $TabletPanel/EndMenu/RematchButton
@onready var _main_menu_button: Button = $TabletPanel/EndMenu/MainMenuButton


func _ready() -> void:
	_send_game_file_button.pressed.connect(_on_send_game_file_button_pressed)
	_continue_button.pressed.connect(_on_continue_button_pressed)
	_rematch_button.pressed.connect(_on_rematch_button_pressed)
	_main_menu_button.pressed.connect(_on_main_menu_button_pressed)


func show_end_menu(winner: BoardGame.Player, hotseat: bool) -> void:
	show()
	
	# Set title
	if hotseat:
		_header_label.text = HOTSEAT_TEXT % (winner + 1)
	else:
		if winner == BoardGame.Player.ONE:
			_header_label.text = WIN_SINGLEPLAYER_TEXT
		else:
			_header_label.text = LOSE_SINGLEPLAYER_TEXT
	
	if Settings.research_mode:
		# TODO update
		_survey_menu.show()
		_end_menu.hide()
		_send_game_file_button.disabled = false
		# Set survey link with the game ID attached
		#survey_button.uri = SURVEY_LINK + "?gameid=" + GameDataCollector.current_game_data.uuid
	else:
		_survey_menu.hide()
		_end_menu.show()


func _on_rematch_button_pressed() -> void:
	visible = false
	rematch_pressed.emit()


func _on_main_menu_button_pressed() -> void:
	visible = false
	exit_pressed.emit()


func _on_continue_button_pressed() -> void:
	_survey_menu.hide()
	_end_menu.show()


func _on_send_game_file_button_pressed() -> void:
	#GameDataCollector.send_game_record_to_server() # TODO
	_send_game_file_button.disabled = true
