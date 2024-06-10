class_name Endscreen extends Control

@export_multiline var survey_link: String = "https://www.universiteitleiden.nl/"
@export var fading_duration = 1.5

@onready var survey_menu = $SurveyScreen as Control
@onready var rematch_menu = $RematchScreen as Control
@onready var survey_button = $SurveyScreen/HBoxContainer/SurveyButton/LinkButton as LinkButton
@onready var result_text = $SurveyScreen/Result_Text as Label

const win_singleplayer_text = "You have won!"
const lose_singleplayer_text = "You have lost!"
const hotseat_text = "Player %d won the game"


func display(winner: General.Player):
	## TODO: Get session id
	## NOTE: This would also be the place to alter the link, something like survey_link + session_id
	survey_button.uri = survey_link
	set_result_text(winner + 1)
	visible = true
	survey_menu.visible = true
	Engine.time_scale = 0
	

func set_result_text(winner: General.Player):
	if Settings.is_hotseat_mode:
		result_text.text = hotseat_text % winner
	elif winner == General.Player.ONE:
		result_text.text = win_singleplayer_text
	else: 
		result_text.text = lose_singleplayer_text
	

## Triggers when any of the two buttons on the survey menu is pressed.
func _on_survey_menu_button_pressed():
	## Go to next screen
	survey_menu.visible = false
	rematch_menu.visible = true


func _on_rematch_pressed():
	GameState.is_rematch = true
	_reload_scene()
	
	
func _on_main_menu_pressed():
	GameState.is_rematch = false
	_reload_scene()


## Triggered when To Main Menu pressed or called from [code] _on_rematch_pressed() [/code]
func _reload_scene():
	Engine.time_scale = 1
	rematch_menu.visible = false
	await _fadeout()
	
	## TODO: Replace with loading logic
	get_tree().reload_current_scene()
	
	
# When someone wins the game, we will fadeout and then reload the scene.
func _fadeout():
	var tween = create_tween().tween_property(self, "color:a", 1.0, fading_duration)
	await tween.finished
