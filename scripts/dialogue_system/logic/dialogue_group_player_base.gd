## A DialogueGroupPlayerBase is responsible for choosing which DialogueSequence to play from a DialogueGroup.
## For example, A DialogueGroupPlayer could randomly pick any sequence in the group, or play them in a specific order. 
class_name DialogueGroupPlayerBase
extends Node

var _sequence_player: DialogueSequencePlayer
var _interruption_sequence_player: DialogueSequencePlayer
var _current_group: DialogueGroup

## Tries to play a DialogueSequence in from the group [param group]. Returns whether the operation was successfull.
func play_sequence_from_group(group: DialogueGroup) -> bool:
	if is_busy() and _interruption_sequence_player.is_playing or not check_priority(group):
		return false
		
	var sequence = _pick_sequence(group)
	if sequence == null:
		return false
	
	_current_group = group
	if not is_busy():
		await _sequence_player.play(sequence)
	else:
		await _sequence_player.interrupt()
		await _sequence_player.on_interruption_ready
		await _interruption_sequence_player.play(sequence)
		
	return true
		
		
func assign_sequence_player(sequence_player: DialogueSequencePlayer, _interruption_sequence_player: DialogueSequencePlayer):
	_sequence_player = sequence_player
	
	
func check_priority(new_group: DialogueGroup):
	if _current_group == null: return true
	return not _current_group.has_priority and new_group.has_priority 


func is_busy():
	## TODO: Double-check
	return _sequence_player.is_playing


## Virtual method
func _pick_sequence(group: DialogueGroup) -> DialogueSequence:
	return null

