extends CanvasLayer


const win_singleplayer_text = "You have won!"
const lose_singleplayer_text = "You have lost!"
const hotseat_text = "Player %d won the game"

@export_multiline var survey_link: String = "https://www.universiteitleiden.nl/"

@onready var header_label: Label = $"End Screen Menu/TabletPanel/HeaderLabel"
@onready var survey_menu: VBoxContainer = $TabletPanel/SurveyMenu
@onready var end_menu: VBoxContainer = $TabletPanel/EndMenu
@onready var survey_button: LinkButton = $TabletPanel/SurveyMenu/HBoxContainer/SurveyButton


func _ready() -> void:
	visible = false
	GameEvents.game_ended.connect(_on_game_ended)


func _on_game_ended(winner: General.Player) -> void:
	visible = true
	
	# Set title
	if Settings.is_hotseat_mode:
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
	GameEvents.play_pressed.emit()


func _on_main_menu_button_pressed() -> void:
	pass # Replace with function body.
