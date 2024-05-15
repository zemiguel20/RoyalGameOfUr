class_name DialogueGroupPlayerRandom
extends DialogueGroupPlayerBase

func _pick_sequence(group: DialogueGroup) -> DialogueSequence:
	var total_weigth = 0
	for sequence in group.dialogue_sequences:
		total_weigth += sequence.weight
		
	var current_weight = 0
	var random_num = randi_range(0, total_weigth - 1)
	for sequence in group.dialogue_sequences:
		current_weight += sequence.weight
		if random_num < current_weight:
			return sequence
			
	push_error("DialogueGroupPlayerRandom: Expected to have picked a sequence by now...")
	return null
