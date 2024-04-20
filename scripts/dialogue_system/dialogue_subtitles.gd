class_name DialogueSubtitles
extends CanvasLayer


@onready var panel := $Background_Panel as Panel
@export var subtitle_label: Label
static var instance

## Text of the opponent npc, which gets saved when another one is shown.
var unfocussed_text
## Focussed on the main character or not.
var focussed: bool = true

func _ready():
	instance = self
	hide_subtitles()
	subtitle_label.text = ""
	
	
func display_subtitle(text: String):
	if focussed:
		subtitle_label.text = text
	else: 
		unfocussed_text = text
	_toggle_subtitles(true)

	
func hide_subtitles():
	_toggle_subtitles(false)


func _toggle_subtitles(toggle: bool):
	panel.visible = toggle


## TODO: Change Names
func _on_area_3d_mouse_entered():
	_toggle_subtitles(true)
	
	unfocussed_text = subtitle_label.text
	focussed = false
	subtitle_label.text = "KitchenStaff: Je moeder"


## TODO: Change Names
func _on_option_1_mouse_exited():
	focussed = true
	subtitle_label.text = unfocussed_text
