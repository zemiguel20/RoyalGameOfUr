## System with a collection of DialogueGroups.
## These dialogs are then played by 
class_name DialogueSystem
extends Node

## List of all dialogues used by this dialog system.
@export var dialogue_list: Array[DialogueGroup] 
@export var _temp_interruption: DialogueGroup 
@onready var dialogue_player = $DialogueGroupPlayer as DialogueGroupPlayer
@onready var interruption_player = $InterruptionPlayer as DialogueGroupPlayer
var _current_index = 0

func play_next():
	if not has_next():
		push_warning("DialogueSystem.play_next(): Dialogue System does not have another entry, yet it was asked to play a next one!")
	
	# Plays the next group of dialogue
	var next_group = dialogue_list[_current_index]
	_current_index += 1
	await dialogue_player.play(next_group)
	
	
func has_next():
	return _current_index < dialogue_list.size()
	
	
func interrupt():
	dialogue_player.interrupt()
	await dialogue_player.on_interruption_ready
	await interruption_player.play(_temp_interruption)
	## FIXME: If we end with an interruption, we will continue, rather than finish. Not intended.
	dialogue_player.continue_dialogue()
