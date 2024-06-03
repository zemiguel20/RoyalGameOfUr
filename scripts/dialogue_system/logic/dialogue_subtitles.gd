class_name DialogueSubtitles
extends CanvasLayer


@onready var panel := $Background_Panel as Panel
@onready var cuneiform_label := $Background_Panel/Cuneiform_Label as Label

@export var subtitle_label: Label
@export var skip_icon: Control

### Text of the opponent npc, which gets saved when another one is shown.
#var unfocussed_text
### Focussed on the main character or not.
#var focussed: bool = true

func _ready():
	hide_subtitles()
	subtitle_label.text = "Waarom doet ie niet?"
	
	
func display_subtitle(entry: DialogueSingleEntry, show_skip_icon: bool):
	subtitle_label.text = entry.caption
	if entry.caption_cuneiform.is_empty():
		cuneiform_label.text = _filter_symbols(entry.caption).to_lower()
	else:
		cuneiform_label.text = entry.caption_cuneiform.to_lower()
		
	_toggle_subtitles(true)
	_toggle_skip_icon(show_skip_icon)


func _filter_symbols(text: String) -> String:
	var result = text.replace(' ', '')
	var chars_to_filter = ['(', ')', '!', '?', ',', '.', '\'', '´', '’']
	for char in chars_to_filter:
		result = result.replace(char, ' ')
	
	return result.substr(0, result.length() / 3)


func hide_subtitles():
	_toggle_subtitles(false)


func _toggle_subtitles(toggle: bool):
	panel.visible = toggle
	
	
func _toggle_skip_icon(toggle: bool):
	skip_icon.visible = toggle


### TODO: Change Names
#func _on_area_3d_mouse_entered():
	#_toggle_subtitles(true)
	#
	#unfocussed_text = subtitle_label.text
	#focussed = false
	#subtitle_label.text = "KitchenStaff: Je moeder"
#
#
### TODO: Change Names
#func _on_option_1_mouse_exited():
	#focussed = true
	#subtitle_label.text = unfocussed_text
