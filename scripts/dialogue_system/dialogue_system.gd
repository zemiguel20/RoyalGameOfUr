## System with a collection of DialogueGroups.
## These dialogs are then played by 
class_name DialogueSystem
extends Node

## List of all dialogues used by this dialog system.
@export var dialogue_list: Array[DialogueGroup] 
@export var _temp_interruption: DialogueGroup 
@onready var _dialogue_player = $DialogueGroupPlayer as DialogueGroupPlayer
@onready var _interruption_player = $InterruptionPlayer as DialogueGroupPlayer
var _current_index = 0

func play_next():
	if not has_next():
		push_warning("DialogueSystem.play_next(): Dialogue System does not have another entry, yet it was asked to play a next one!")
	
	# Plays the next group of dialogue
	var next_group = dialogue_list[_current_index]
	_current_index += 1
	await _dialogue_player.play(next_group)
	
	
func has_next():
	return _current_index < dialogue_list.size()
	
	
func interrupt():
	## TODO: For the prototype this is fine, but we might reconsider this later.
	## I put a todo just to not forget this part.
	if _interruption_player.is_playing:
		return
	
	if _dialogue_player.is_playing:
		_dialogue_player.interrupt()
		await _dialogue_player.on_interruption_ready
	await _interruption_player.play(_temp_interruption)
	## FIXME: If we end with an interruption, we will continue, rather than finish. Not intended.
	_dialogue_player.continue_dialogue()
