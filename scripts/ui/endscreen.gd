class_name Endscreen extends Control

## Question: How does this class get the session id?
@export_multiline var survey_link: String = "https://www.universiteitleiden.nl/"

@onready var survey_menu = $SurveyScreen as Control
@onready var rematch_menu = $RematchScreen as Control
@onready var survey_button = $SurveyScreen/HBoxContainer/SurveyButton/LinkButton as LinkButton
@onready var result_text = $SurveyScreen/Result_Text as Label

const win_singleplayer_text = "You have won!"
const lose_singleplayer_text = "You have lost!"
const hotseat_text = "Player %d won the game"


func _ready():
	pass
	
	
func display(player: General.Player):
	## TODO: Get session id
	## NOTE: This would also be the place to alter the link, something like survey_link + session_id
	survey_button.uri = survey_link
	set_result_text(player)
	visible = true
	survey_menu.visible = true
	Engine.time_scale = 0
	

func set_result_text(player: General.Player):
	if Settings.current_gamemode == Settings.Gamemode.Hotseat:
		result_text.text = hotseat_text % player
	elif player == General.Player.ONE:
		result_text.text = win_singleplayer_text
	else: 
		result_text.text = lose_singleplayer_text
	

## Triggers when any of the buttons on the survey menu is pressed
func _on_survey_menu_button_pressed():
	## Go to next screen
	survey_menu.visible = false
	rematch_menu.visible = true


func _on_rematch_pressed():
	Engine.time_scale = 1	
	get_tree().reload_current_scene()
	print("Does this execute?")
	GameEvents.rematch_triggered.emit()


func _on_main_menu_pressed():
	Engine.time_scale = 1		
	get_tree().reload_current_scene()
