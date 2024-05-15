## Node responsible for executing a DialogueGroup, which consists of audio and subtitles.
class_name DialogueSequencePlayer
extends Node

## Signal that emits when the current sequence of dialogue has been finished.
signal on_dialogue_finished
signal on_interruption_ready

@export var _use_subtitles: bool
## NOTE: Since we do not have audio for the playtest, we have a constant waiting time.
@export var _temp_max_entry_length: float = 3.0

## Giving these through a setup function might be nice.
@onready var _audio_player = $AudioStreamPlayer3D as AudioStreamPlayer3D
@onready var _animation_player =  $"../../AnimationPlayer" as OpponentAnimationPlayer
@onready var _subtitle_displayer = $"../../Subtitle_System" as DialogueSubtitles

var is_playing: bool
var _current_sequence: DialogueSequence
var _current_index = 0
var _is_interrupted


func play(sequence: DialogueSequence):
	_current_sequence = sequence
	_current_index = 0
	continue_dialogue()
	await on_dialogue_finished


## TODO: Check this description
## Used for when the dialogue was interrupted after one of the dialogue entries.
## Will continue playing the next entry.
func continue_dialogue():
	if _current_index >= _current_sequence.dialogue_entries.size():
		finish_sequence()
		return
		
	is_playing = true
	var _current_entry = _current_sequence.dialogue_entries[_current_index] as DialogueSingleEntry
	
	# Play all the effects
	if _current_entry.audio != null:
		_audio_player.stream = _current_entry.audio
		_audio_player.play()
	if _use_subtitles and _current_entry.caption != null:
		_subtitle_displayer.display_subtitle(_current_entry.caption)
	## TODO: Change, maybe we should give the whole list, and let the whole list play in a random order, 
	## but dont start a new animation if the 
	if _current_entry.anim_variations != null and _current_entry.anim_variations.size() > 0:	
		_animation_player.play_animation(_current_entry.anim_variations[0], true)
		
	# Wait for audio to be over.
	## TODO: Revert back when audio is actually there.
	var entry_length = maxf(_temp_max_entry_length, _animation_player.current_animation_length)
	await get_tree().create_timer(entry_length).timeout
	_current_index += 1
	
	if _is_interrupted:
		handle_interruption()
	else:
		continue_dialogue()
		
		
func finish_sequence():
	if _use_subtitles:
		_subtitle_displayer.hide_subtitles()
		
	on_dialogue_finished.emit()
	on_interruption_ready.emit()
	is_playing = false
	
	
func handle_interruption():
	if _use_subtitles:
		_subtitle_displayer.hide_subtitles()
		
	on_interruption_ready.emit()
	_is_interrupted = false	
	is_playing = false
	
	
func interrupt():
	_is_interrupted = true

