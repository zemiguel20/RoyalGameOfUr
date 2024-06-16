extends CanvasLayer


const win_singleplayer_text = "You have won!"
const lose_singleplayer_text = "You have lost!"
const hotseat_text = "Player %d won the game"

@export_multiline var survey_link: String = "https://www.universiteitleiden.nl/"

@onready var header_label: Label = $TabletPanel/HeaderLabel
@onready var survey_menu: VBoxContainer = $TabletPanel/SurveyMenu
@onready var end_menu: VBoxContainer = $TabletPanel/EndMenu
@onready var survey_button: LinkButton = $TabletPanel/SurveyMenu/HBoxContainer/SurveyButton


func _ready() -> void:
	visible = false
	GameEvents.game_ended.connect(_on_game_ended)


func _on_game_ended() -> void:
	visible = true
	var winner = GameManager.current_player
	
	# Set title
	if GameManager.is_hotseat:
		header_label.text = hotseat_text % (winner + 1)
	else:
		if winner == General.Player.ONE:
			header_label.text = win_singleplayer_text
		else:
			header_label.text = lose_singleplayer_text
	
	# TODO: IMPLEMENT SURVEY
	survey_menu.visible = false
	end_menu.visible = true


func _on_rematch_button_pressed() -> void:
	visible = false
	GameManager.is_rematch = true
	GameEvents.play_pressed.emit()
	GameManager.start_new_game()


func _on_main_menu_button_pressed() -> void:
	visible = false
	GameEvents.back_to_main_menu_pressed.emit()
