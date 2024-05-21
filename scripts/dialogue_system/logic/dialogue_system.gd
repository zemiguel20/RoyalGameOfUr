class_name DialogueSystem
extends Node

enum Category {
	INTRO_STORY = 0,
	INTRO_RULES_QUESTION = 1,
	INTRO_GAME_START = 2,
	GAME_OPPONENT_GETS_CAPTURED = 3,
	GAME_PLAYER_GETS_CAPTURED = 4,
	GAME_OPPONENT_MISTAKE = 5,
	GAME_PLAYER_MISTAKE = 6,
	GAME_OPPONENT_WIN = 7,
	GAME_PLAYER_WIN = 8,
	GAME_OPPONENT_WAITING = 9,
	GAME_OPPONENT_THINKING = 10,
	RANDOM_CONVERSATION = 11,
}

@export var _dialogue_groups: Array[DialogueGroup]

@onready var _player_inorder = $DialogueGroupPlayer_InOrder as DialogueGroupPlayerBase
@onready var _player_random = $DialogueGroupPlayer_Random as DialogueGroupPlayerBase
@onready var _dialogue_sequence_player = $DialogueSequencePlayer as DialogueSequencePlayer
@onready var _interruption_sequence_player = $InterruptionSequencePlayer as DialogueSequencePlayer

var _current_dialogue_player: DialogueGroupPlayerBase


func _ready():
	_player_inorder.assign_sequence_player(_dialogue_sequence_player, _interruption_sequence_player)
	_player_random.assign_sequence_player(_dialogue_sequence_player, _interruption_sequence_player)


## Tries to play a DialogueSequence in the correct category. Returns whether the operation was successfull.
func play(category: Category) -> bool:
	if is_busy() and _interruption_sequence_player.is_busy():
		return false
		
	for group in _dialogue_groups:
		if group.category == category:
			var group_player = _player_inorder if group.play_in_order else _player_random
			_current_dialogue_player = group_player
			var success = await group_player.play_sequence_from_group(group)
			_current_dialogue_player = null
			return success
			
	return false

	
func is_busy() -> bool:
	return _player_inorder.is_busy() or _player_random.is_busy()
	
func can_interrupt():
	return not _interruption_sequence_player.is_busy()