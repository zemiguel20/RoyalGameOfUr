class_name DialogueGroupPlayerRandom
extends DialogueGroupPlayerBase

func _pick_sequence(group: DialogueGroup) -> DialogueSequence:
	var available_sequences = group.dialogue_sequences.duplicate()
	for sequence in group.dialogue_sequences:
		if sequence.was_played and available_sequences.has(sequence):
			available_sequences.erase(sequence)
	## If all sequences have been played, reset the list
	if available_sequences.is_empty():
		for sequence in group.dialogue_sequences:
			sequence.was_played = false
		available_sequences = group.dialogue_sequences.duplicate()
	
	var total_weight = 0
	for sequence in available_sequences:
		total_weight += sequence.weight
		
	var current_weight = 0
	var random_num = randi_range(0, total_weight - 1)
	for sequence in available_sequences:
		current_weight += sequence.weight
		if random_num < current_weight:
			sequence.was_played = true
			return sequence
			
	push_error("DialogueGroupPlayerRandom: Expected to have picked a sequence by now...")
	return null
