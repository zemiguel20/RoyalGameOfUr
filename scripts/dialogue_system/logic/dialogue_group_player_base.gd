## A DialogueGroupPlayerBase is responsible for choosing which DialogueSequence to play from a DialogueGroup.
## For example, A DialogueGroupPlayer could randomly pick any sequence in the group, or play them in a specific order. 
class_name DialogueGroupPlayerBase
extends Node

var _sequence_player: DialogueSequencePlayer


## Tries to play a DialogueSequence in from the group [param group]. Returns whether the operation was successfull.
func play_sequence_from_group(group: DialogueGroup) -> bool:
	var sequence = _pick_sequence(group)
	if sequence != null:
		_sequence_player.play(sequence)
		return true
	else:
		return false
		
		
func assign_sequence_player(sequence_player: DialogueSequencePlayer):
	_sequence_player = sequence_player


func is_busy():
	## TODO: Double-check
	return _sequence_player.is_playing


## Virtual method
func _pick_sequence(group: DialogueGroup) -> DialogueSequence:
	return null

