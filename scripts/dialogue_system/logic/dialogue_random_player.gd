class_name DialogueGroupPlayerRandom
extends DialogueGroupPlayerBase

var last_picked_sequence

func _pick_sequence(group: DialogueGroup) -> DialogueSequence:
	var available_sequences = group.dialogue_sequences.duplicate()
	for sequence in group.dialogue_sequences:
		if sequence.times_played >= sequence.max_repetitions or sequence == last_picked_sequence:
			if available_sequences.is_empty():
				return null
			if available_sequences.has(sequence):
				available_sequences.erase(sequence)
			return
	
	var total_weight = 0
	for sequence in available_sequences:
		total_weight += sequence.weight
		
	var current_weight = 0
	var random_num = randi_range(0, total_weight - 1)
	for sequence in available_sequences:
		current_weight += sequence.weight
		if random_num < current_weight:
			sequence.times_played += 1
			
			last_picked_sequence = sequence
			return sequence
			
	push_error("DialogueGroupPlayerRandom: Expected to have picked a sequence by now...")
	return null
