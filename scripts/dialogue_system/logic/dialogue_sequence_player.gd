## Node responsible for executing a DialogueGroup, which consists of audio and subtitles.
class_name DialogueSequencePlayer
extends Node

## Signal that emits when the current sequence of dialogue has been finished.
signal on_dialogue_finished
signal on_interruption_ready

@export var _use_subtitles: bool

@onready var _audio_player = $AudioStreamPlayer3D as AudioStreamPlayer3D
@onready var _subtitle_displayer = $"../Subtitle_System" as DialogueSubtitles
@onready var _dialogue_menu_controller = $"../Menus_During_Dialogue" as DialogueMenuController
var _animation_player: AnimationPlayer

var is_playing: bool
var _current_sequence: DialogueSequence
var _current_index = -1
var _is_interrupted
var _already_prevents_opponent_action: bool


func play(sequence: DialogueSequence):
	_current_sequence = sequence
	_current_index = -1
	continue_dialogue()
	await on_dialogue_finished


## TODO: Solve with a blackboard.
func continue_dialogue():
	_current_index += 1
	if _current_index >= _current_sequence.dialogue_entries.size():
		finish_sequence()
		return
		
	is_playing = true
	var _current_entry = _current_sequence.dialogue_entries[_current_index]
	
	## Handle dialogue events
	if _current_entry is DialogueBundle:
		await play_dialogue_bundle(_current_entry) 
	else:
		await _current_entry.execute(_dialogue_menu_controller)
		continue_dialogue()
	
		
func play_dialogue_bundle(_current_entry):
	_current_entry = _current_entry as DialogueBundle
	
	# Play all the effects
	var audios = _current_entry.audio_variations
	if audios != null and audios.size() > 0:
		_audio_player.stream = audios.pick_random()
		_audio_player.play()
	if _use_subtitles and _current_entry.caption != null:
		_subtitle_displayer.display_subtitle(_current_entry, _current_sequence.requires_click)
	## TODO: Change, maybe we should give the whole list, and let the whole list play in a random order, 
	if _current_entry.anim_variations != null and _current_entry.anim_variations.size() > 0:	
		_animation_player.play_animation(_current_entry.anim_variations[0], false)
		
	_handle_opponent_action_prevention(_current_entry)
	if not _current_sequence.requires_click:
		# Wait for audio to be over.
		## TODO: Revert back when audio is actually there.
		var entry_length = _current_entry.fixed_duration
		if entry_length == -1:
			await _audio_player.finished
		else:
			await get_tree().create_timer(entry_length).timeout
			
		continue_dialogue()


func skip():
	if not is_busy() or not _current_sequence.requires_click:
		return
	
	## Stop players
	_audio_player.stop()
	#_animation_player.cancel_animation()
	_subtitle_displayer.hide_subtitles()
	
	continue_dialogue()
		
		
func finish_sequence():
	if _use_subtitles:
		_subtitle_displayer.hide_subtitles()
		
	is_playing = false
	on_dialogue_finished.emit()
	on_interruption_ready.emit()
	
	if _already_prevents_opponent_action:
		_already_prevents_opponent_action = false
		#GameEvents.opponent_action_resumed.emit()


func set_animation_player(animation_player: AnimationPlayer):
	_animation_player = animation_player
	

func _handle_opponent_action_prevention(entry: DialogueBundle):
	if entry.prevents_opponent_action and !_already_prevents_opponent_action:
		_already_prevents_opponent_action = true
		#GameEvents.opponent_action_prevented.emit()
	elif !entry.prevents_opponent_action and _already_prevents_opponent_action:
		_already_prevents_opponent_action = false
		#GameEvents.opponent_action_resumed.emit()


func stop():
	_audio_player.stop()
	_animation_player.stop()
	_subtitle_displayer.hide_subtitles() 


func handle_interruption():
	if _use_subtitles:
		_subtitle_displayer.hide_subtitles()
		
	## Rename to something like on_has_paused
	is_playing = false
	on_interruption_ready.emit()
	_is_interrupted = false	
	
	
func interrupt():
	_is_interrupted = true
	

func is_busy():
	return is_playing
