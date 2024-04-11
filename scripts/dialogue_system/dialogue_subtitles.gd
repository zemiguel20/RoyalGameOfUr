class_name DialogueSubtitles
extends CanvasLayer

@export var subtitle_label: Label

func _ready():
	hide_subtitles()
	subtitle_label.text = ""

func display_subtitle(text: String):
	subtitle_label.text = text
	_toggle_subtitles(true)

	
func hide_subtitles():
	_toggle_subtitles(false)


func _toggle_subtitles(toggle: bool):
	visible = toggle
