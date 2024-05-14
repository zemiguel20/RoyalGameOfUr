class_name DialogueGroupPlayer
extends Node

var sequence_player: DialogueSequencePlayer

func play_sequence():
	var sequence = _pick_sequence()
	sequence_player.play(sequence)


## Virtual method
func _pick_sequence() -> DialogueSequence:
	return null
