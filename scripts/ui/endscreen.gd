extends Control

## Question: How does this class get the session id?
@export var survey_link: String = "https://www.universiteitleiden.nl/"

@onready var survey_menu = $SurveyScreen as Control
@onready var rematch_menu = $RematchScreen as Control
@onready var survey_button = $SurveyScreen/HBoxContainer/SurveyButton/LinkButton as LinkButton
@onready var result_text = $SurveyScreen/Result_Text as Label

const win_singleplayer_text = "You have won!"
const lose_singleplayer_text = "You have lost!"
const hotseat_text = "Player %d won the game"


func _on_game_ended(player: General.Player):
	if Settings.current_gamemode == Settings.Gamemode.Hotseat:
		result_text.text = hotseat_text % player
	elif player == General.Player.ONE:
		result_text.text = win_singleplayer_text
	else: 
		result_text.text = lose_singleplayer_text
	
	## TODO: Get session id
	## NOTE: This would also be the place to alter the link, something like survey_link + session_id
	survey_button.uri = survey_link
	visible = true
	survey_menu.visible = true
	

## Triggers when any of the buttons on the survey menu is pressed
func _on_survey_menu_button_pressed():
	## Go to next screen
	survey_menu.visible = false
	rematch_menu.visible = true


func _on_rematch_pressed():
	## Restart the scene -> Send global signal?
	get_tree().reload_current_scene()


func _on_main_menu_pressed():
	## Load Main Menu -> Send global signal?
	print("To Main Menu")
	push_warning("Endscreen Main Menu Button: Not Implemented")
