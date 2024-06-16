class_name EndScreen extends CanvasLayer


signal back_pressed

const WIN_SINGLEPLAYER_TEXT = "You have won!"
const LOSE_SINGLEPLAYER_TEXT = "You have lost!"
const HOTSEAT_TEXT = "Player %d won the game"

@export_multiline var survey_link: String = "https://www.universiteitleiden.nl/"


@export_group("References")
@export var header_label: Label
@export var survey_menu: Control
@export var end_menu: Control
@export var survey_button: LinkButton


func _ready() -> void:
	GameEvents.game_ended.connect(_on_game_ended)


func _on_game_ended() -> void:
	visible = true
	var winner = GameManager.current_player
	
	# Set title
	if GameManager.is_hotseat:
		header_label.text = HOTSEAT_TEXT % (winner + 1)
	else:
		if winner == General.Player.ONE:
			header_label.text = WIN_SINGLEPLAYER_TEXT
		else:
			header_label.text = LOSE_SINGLEPLAYER_TEXT
	
	survey_menu.visible = true
	end_menu.visible = false
	
	# TODO: IMPLEMENT SURVEY
	survey_button.uri = survey_link


func _on_rematch_button_pressed() -> void:
	GameEvents.play_pressed.emit()
	GameManager.is_rematch = true
	GameManager.start_new_game()


func _on_main_menu_button_pressed() -> void:
	back_pressed.emit()
	GameEvents.back_to_main_menu_pressed.emit()


func _on_continue_button_pressed() -> void:
	survey_menu.visible = false
	end_menu.visible = true
