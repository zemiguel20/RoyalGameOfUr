## System that handles playing a collection of DialogueGroups.
## These dialogs are then played by a DialogueGroupPlayer.
## Each NPC will contain a DialogueCollectionPlayer.
class_name DialogueCollectionPlayer
extends Node

## List of all dialogues used by this dialog system.
@export var _dialogue_list: Array[DialogueGroup] 
@export var _supports_interruptions: bool
@export var _temp_interruption: DialogueGroup 

@onready var _dialogue_player = $DialogueGroupPlayer as DialogueGroupPlayer
@onready var _interruption_player = $InterruptionPlayer as DialogueGroupPlayer

var _current_index = 0

func play_next():
	if not has_next():
		push_warning("DialogueCollectionPlayer.play_next(): Dialogue System does not have another entry, yet it was asked to play a next one!")
	
	# Plays the next group of dialogue
	var next_group = _dialogue_list[_current_index]
	_current_index += 1
	await _dialogue_player.play(next_group)
	
	
func has_next():
	return _current_index < _dialogue_list.size()
	
	
func interrupt():
	if not _supports_interruptions:
		push_warning("DialogueCollectionPlayer.interrupt(): This dialogue system does not support interruptions")
	
	## TODO: For the prototype this is fine, but we might reconsider this later.
	## I put a todo just to not forget this part.
	if _interruption_player.is_playing:
		return
	
	if _dialogue_player.is_playing:
		_dialogue_player.interrupt()
		await _dialogue_player.on_interruption_ready
	await _interruption_player.play(_temp_interruption)
	_dialogue_player.continue_dialogue()


func is_busy():
	return _dialogue_player.is_playing or (_supports_interruptions and _interruption_player.is_playing)
