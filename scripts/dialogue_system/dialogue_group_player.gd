## Node responsible for executing 
class_name DialogueGroupPlayer
extends Node

## Signal that emits when the current group of dialogue has been finished.
signal on_dialogue_finished

var _current_group: DialogueGroup
var _current_index = 0
var _is_interrupted

@onready var audio_player = $AudioStreamPlayer3D as AudioStreamPlayer
@onready var subtitle_displayer = $DialogueSubtitles_CanvasLayer as DialogueSubtitles


func play(group):
	_current_group = group
	_current_index = 0
	continue_dialogue()
	await on_dialogue_finished


## Used for when the dialogue was interrupted after one of the dialogue entries.
## Will continue playing the next entry.
func continue_dialogue():
	var _current_entry = _current_group.dialogue_entries[_current_index] as DialogueSingleEntry
	audio_player = $AudioStreamPlayer3D as AudioStreamPlayer3D
	audio_player.stream = _current_entry.audio
	audio_player.play()
	# Show subtitles
	print(_current_entry.subtitle)
	subtitle_displayer.display_subtitle(_current_entry.subtitle)
	var clip_length = _current_entry.audio.get_length()
	await get_tree().create_timer(clip_length).timeout
	_current_index += 1
	
	if _current_index < _current_group.dialogue_entries.size() and not _is_interrupted:
		continue_dialogue()
	elif _current_index >=  _current_group.dialogue_entries.size():
		on_dialogue_finished.emit()
		subtitle_displayer.hide_subtitles()
	
	
func interrupt():
	_is_interrupted = true

