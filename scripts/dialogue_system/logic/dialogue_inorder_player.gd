class_name DialogueGroupPlayerInOrder
extends DialogueGroupPlayerBase

## List of all dialogues used by this dialog system.

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
