class_name DialogueGroupPlayerInOrder
extends DialogueGroupPlayerBase

## List of all dialogues used by this dialog system.
@export var _supports_interruptions: bool
@export var _temp_interruption: DialogueGroup 

## TODO: IDK
#@onready var _interruption_player = $InterruptionPlayer as DialogueGroupPlayerBase

var _current_dialogues: Array[DialogueSequence]
var _current_index = -1

func _pick_sequence(group: DialogueGroup) -> DialogueSequence:
	if _current_dialogues != group.dialogue_sequences:
		_current_index = -1
		_current_dialogues = group.dialogue_sequences
		push_warning("DialogueGroupPlayerInOrder: Override previous group")
	
	if not has_next():
		push_warning("DialogueCollectionPlayer.play_next(): Dialogue System does not have another entry, yet it was asked to play a next one!")
		return null
	
	_current_index += 1
	return group.dialogue_sequences[_current_index]
	

func has_next():
	return _current_index + 1 < _current_dialogues.size()
	
	
## Resets any progress on a dialogue_group
func reset():
	_current_index = -1
	_current_dialogues = []
	
	
## TODO: Idk how to handle interruptions yet.
#func interrupt():
	#if not _supports_interruptions:
		#push_warning("DialogueCollectionPlayer.interrupt(): This dialogue system does not support interruptions")
	#
	### TODO: For the prototype this is fine, but we might reconsider this later.
	### I put a todo just to not forget this part.
	#if _interruption_player.is_playing:
		#return
	#
	#if _sequence_player.is_playing:
		#_sequence_player.interrupt()
		#await _sequence_player.on_interruption_ready
	#await _interruption_player.play(_temp_interruption)
	#_sequence_player.continue_dialogue()


