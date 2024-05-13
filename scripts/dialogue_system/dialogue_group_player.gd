## Node responsible for executing a DialogueGroup, which consists of audio and subtitles.
class_name DialogueGroupPlayer
extends Node

## Signal that emits when the current group of dialogue has been finished.
signal on_dialogue_finished
signal on_interruption_ready

@export var _use_subtitles: bool
var is_playing: bool
var _current_group: DialogueGroup
var _current_index = 0
var _is_interrupted

@onready var audio_player = $AudioStreamPlayer3D as AudioStreamPlayer3D
@onready var subtitle_displayer


func play(group):
	_current_group = group
	_current_index = 0
	continue_dialogue()
	await on_dialogue_finished


## TODO: Check this description
## Used for when the dialogue was interrupted after one of the dialogue entries.
## Will continue playing the next entry.
func continue_dialogue():
	if _current_index >= _current_group.dialogue_entries.size():
		finish_group()
		return
		
	is_playing = true
	var _current_entry = _current_group.dialogue_entries[_current_index] as DialogueSingleEntry
	audio_player.stream = _current_entry.audio
	audio_player.play()
	if _use_subtitles:
		DialogueSubtitles.instance.display_subtitle(_current_entry.subtitle)
		
	# Wait for audio to be over.
	var clip_length = _current_entry.audio.get_length()
	await get_tree().create_timer(clip_length).timeout
	_current_index += 1
	
	if _is_interrupted:
		handle_interruption()
	else:
		continue_dialogue()
		
		
func finish_group():
	if _use_subtitles:
		DialogueSubtitles.instance.hide_subtitles()
		
	on_dialogue_finished.emit()
	on_interruption_ready.emit()
	is_playing = false
	
	
func handle_interruption():
	if _use_subtitles:
		DialogueSubtitles.instance.hide_subtitles()
		
	on_interruption_ready.emit()
	_is_interrupted = false	
	is_playing = false
	
	
func interrupt():
	_is_interrupted = true

