class_name DialogueSystem
extends Node

enum Category {
	STORY, 
	OPPONENT_KNOCKED_OUT,
	PLAYER_KNOCKED_OUT,
	OPPONENT_WAITING
}

@export var _dialogue_groups: Array[DialogueGroup]

@onready var _player_inorder = $DialogueGroupPlayer_InOrder as DialogueGroupPlayerBase
@onready var _player_random = $DialogueGroupPlayer_Random as DialogueGroupPlayerBase
@onready var _dialogue_sequence_player = $DialogueSequencePlayer as DialogueSequencePlayer
@onready var _interruption_sequence_player = $InterruptionSequencePlayer as DialogueSequencePlayer


func _ready():
	_player_inorder.assign_sequence_player(_dialogue_sequence_player)
	_player_random.assign_sequence_player(_dialogue_sequence_player)
	

## Tries to play a DialogueSequence in the correct category. Returns whether the operation was successfull.
func play(category: Category) -> bool:
	for group in _dialogue_groups:
		if group.category == category:
			var group_player = _player_inorder if group.play_in_order else _player_random
			return group_player.play_sequence_from_group(group)
			
	return false
	
	
func is_busy() -> bool:
	return _player_inorder.is_busy() or _player_random.is_busy()
	
	
