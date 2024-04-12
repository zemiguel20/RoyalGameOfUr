class_name DialogueSubtitles
extends CanvasLayer

@export var subtitle_label: Label
@onready var interrupt = $"Background_Panel/E to Interrupt" as Label

func _ready():
	hide_subtitles()
	subtitle_label.text = ""
	
	
func _input(event):
	if event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_E:
		if interrupt:
			interrupt.modulate = Color.RED
			interrupt.text = "Key Pressed, will interrupt after sentence"
		

func display_subtitle(text: String):
	subtitle_label.text = text
	_toggle_subtitles(true)

	
func hide_subtitles():
	_toggle_subtitles(false)
	if interrupt:
		interrupt.modulate = Color.WHITE	
		interrupt.text = "Press E to interrupt"


func _toggle_subtitles(toggle: bool):
	visible = toggle
