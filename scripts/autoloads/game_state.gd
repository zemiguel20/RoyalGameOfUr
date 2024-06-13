extends Node


var current_player: General.Player = General.Player.ONE ## Player playing the current turn.
var turn_number: int = 0 ## Total count of the number of turns of the current match.


## Advance turn and switch players.
func advance_turn_switch_player() -> void:
	current_player = General.get_opponent(current_player)
	turn_number += 1
	GameEvents.new_turn_started.emit()


## Advance turn as an extra turn for current player.
func advance_turn_same_player() -> void:
	turn_number += 1
	GameEvents.new_turn_started.emit()


func is_bot_playing() -> bool:
	return current_player == General.Player.TWO and not Settings.is_hotseat_mode
